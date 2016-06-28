describe Fastlane do
  describe Fastlane::FastFile do
    describe "unzip" do
      it "generates a valid unzip command" do
        path = "./fastlane/spec/fixtures/actions/example_action.rb.zip"

        expect(Fastlane::Actions).to receive(:sh).with("unzip -o ./fastlane/spec/fixtures/actions/example_action.rb.zip", log: false)

        result = Fastlane::FastFile.new.parse("lane :test do
          unzip(file: '#{path}')
        end").runner.execute(:test)
      end
    end
  end
end
