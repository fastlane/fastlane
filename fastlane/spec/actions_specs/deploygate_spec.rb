describe Fastlane do
  describe Fastlane::FastFile do
    describe "DeployGate Integration" do
      it "raises an error if no parameters were given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            deploygate()
          end").runner.execute(:test)
        end.to raise_error
      end

      it "raises an error if no api token was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              user: 'deploygate',
            })
          end").runner.execute(:test)
        end.to raise_error
      end

      it "raises an error if no target user was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              api_token: 'thisistest'
            })
          end").runner.execute(:test)
        end.to raise_error
      end

      it "raises an error if no ipa path was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              api_token: 'thisistest',
              user: 'deploygate'
            })
          end").runner.execute(:test)
        end.to raise_error
      end

      it "raises an error if the given ipa path was not found" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              api_token: 'thisistest',
              user: 'deploygate',
              ipa_path: './fastlane/nonexistent'
            })
          end").runner.execute(:test)
        end.to raise_error
      end

      it "works with valid parameters" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            deploygate({
              ipa: './fastlane/spec/fixtures/fastfiles/Fastfile1',
              user: 'deploygate',
              api_token: 'thisistest',
            })
          end").runner.execute(:test)
        end.not_to raise_error
      end
    end
  end
end
