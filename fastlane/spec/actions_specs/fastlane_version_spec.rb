describe Fastlane do
  describe Fastlane::FastFile do
    describe "fastlane_version action" do
      it "works as expected" do
        Fastlane::FastFile.new.parse("lane :test do
          fastlane_version '0.1'
        end").runner.execute(:test)
      end

      it "raises an exception if it's an old version" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            fastlane_version '9999'
          end").runner.execute(:test)
        end.to raise_error("The Fastfile requires a fastlane version of >= 9999. You are on #{Fastlane::VERSION}. Please update using `sudo gem update fastlane`.".red)
      end

      it "raises an error if no team ID is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            fastlane_version
          end").runner.execute(:test)
        end.to raise_error("Please pass minimum fastlane version as parameter to fastlane_version".red)
      end
    end
  end
end
