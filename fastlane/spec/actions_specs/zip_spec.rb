describe Fastlane do
  describe Fastlane::FastFile do
    describe "zip" do
      it "generates a valid zip command" do
        path = "./fastlane/spec/fixtures/actions/archive.rb"

        expect(Fastlane::Actions).to receive(:sh).with("zip -r ./fastlane/spec/fixtures/actions/archive.rb.zip archive.rb")

        result = Fastlane::FastFile.new.parse("lane :test do
          zip(path: '#{path}')
        end").runner.execute(:test)
      end
    end
  end
end
