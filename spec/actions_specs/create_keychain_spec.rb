describe Fastlane do
  describe Fastlane::FastFile do
    describe "Unlock keychain Integration" do

      it "works with path and password and existing keychain" do
        expanded_path = File.expand_path("~/Library/Keychains/login.keychain")

        result = Fastlane::FastFile.new.parse("lane :test do
          unlock_keychain ({
            path: '#{expanded_path}',
            password: 'testpassword',
          })
        end").runner.execute(:test)

        expect(result.size).to eq 2
        expect(result[0]).to eq "security unlock-keychain -p testpassword #{expanded_path}"
        expect(result[1]).to eq "security set-keychain-settings #{expanded_path}"
      end
    end
  end
end
