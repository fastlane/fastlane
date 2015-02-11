describe Fastlane do
  describe Fastlane::FastFile do
    describe "DeployGate Integration" do
      it "raises an error if no parameters were given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            deploygate()
          end").runner.execute(:test)
        }.to raise_error
      end

      it "raises an error if no api token was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              username: 'deploygate',
            })
          end").runner.execute(:test)
        }.to raise_error
      end

      it "raises an error if no target user was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              api_token: 'thisistest'
            })
          end").runner.execute(:test)
        }.to raise_error
      end

      it "raises an error if no ipa path was given" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              api_token: 'thisistest',
              username: 'deploygate',
            })
          end").runner.execute(:test)
        }.to raise_error
      end

      it "raises an error if the given ipa path was not found" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              api_token: 'thisistest',
              username: 'deploygate',
              ipa_path: './fastlane/nonexistent'
            })
          end").runner.execute(:test)
        }.to raise_error
      end

      it "works with valid parameters" do
        expect {
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              username: 'deploygate',
              api_token: 'thisistest',
            })
          end").runner.execute(:test)
        }.not_to raise_error
      end
    end
  end
end
