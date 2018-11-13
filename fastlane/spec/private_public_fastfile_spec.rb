describe Fastlane do
  describe Fastlane::FastFile do
    describe "Public/Private lanes" do
      let(:path) { './fastlane/spec/fixtures/fastfiles/FastfilePrivatePublic' }
      before do
        FileUtils.rm_rf('/tmp/fastlane/')

        @ff = Fastlane::FastFile.new(path)
      end

      it "raise an exception when calling a private lane" do
        expect do
          @ff.runner.execute('private_helper')
        end.to raise_error("You can't call the private lane 'private_helper' directly")
      end

      it "still supports calling public lanes" do
        result = @ff.runner.execute('public')
        expect(result).to eq("publicResult")
      end

      it "supports calling private lanes from public lanes" do
        result = @ff.runner.execute('smooth')
        expect(result).to eq("success")
      end

      it "doesn't expose the private lanes in `fastlane lanes`" do
        require 'fastlane/lane_list'
        result = Fastlane::LaneList.generate(path)
        expect(result).to include("such smooth")
        expect(result).to_not(include("private call"))
      end

      it "doesn't expose the private lanes in `fastlane docs`" do
        output_path = "/tmp/documentation.md"
        ff = Fastlane::FastFile.new(path)
        Fastlane::DocsGenerator.run(ff, output_path)
        output = File.read(output_path)

        expect(output).to include('gem install fastlane')
        expect(output).to include('such smooth')
        expect(output).to_not(include('private'))
      end
    end
  end
end
