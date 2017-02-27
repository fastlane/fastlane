describe Fastlane do
  describe Fastlane::FastFile do
    before do
      @path = "./fastlane/spec/fixtures/actions/archive.rb"
    end

    describe "zip" do
      it "generates a valid zip command" do
        expect(Fastlane::Actions).to receive(:sh).with("zip -r #{@path}.zip archive.rb")

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}')
        end").runner.execute(:test)
      end

      it "generates a valid zip command without verbose output" do
        expect(Fastlane::Actions).to receive(:sh).with("zip -rq #{@path}.zip archive.rb")

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{@path}', verbose: 'false')
        end").runner.execute(:test)
      end
    end
  end
end
