describe Fastlane do
  describe Fastlane::FastFile do
    describe "Unlock keychain Integration" do
      it "works with path and password and existing keychain" do
        keychain_path = Tempfile.new('foo').path

        result = Fastlane::FastFile.new.parse("lane :test do
          unlock_keychain ({
            path: '#{keychain_path}',
            password: 'testpassword',
          })
        end").runner.execute(:test)

        expect(result.size).to eq(2)
        expect(result[0]).to eq("security unlock-keychain -p testpassword #{keychain_path}")
        expect(result[1]).to eq("security set-keychain-settings #{keychain_path}")
      end
    end
  end
end
