describe Fastlane do
  describe Fastlane::FastFile do
    describe "Public/Private lanes" do
      let(:path) { './fastlane/spec/fixtures/fastfiles/FastfilePrivatePublic' }
      # Avoid fixed paths under /tmp: parallel test processes would share them. See fastlane#30184.
      let(:output_dir) { Dir.mktmpdir("fl_spec_docs") }
      let(:output_path) { File.join(output_dir, "documentation.md") }
      after { FileUtils.remove_entry(output_dir) if File.directory?(output_dir) }
      before do
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
        ff = Fastlane::FastFile.new(path)
        Fastlane::DocsGenerator.run(ff, output_path)
        output = File.read(output_path)

        expect(output).to include('installation instructions')
        expect(output).to include('such smooth')
        expect(output).to_not(include('private'))
      end
    end
  end
end
