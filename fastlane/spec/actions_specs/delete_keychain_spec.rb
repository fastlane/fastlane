describe Fastlane do
  describe Fastlane::FastFile do
    describe "Delete keychain Integration" do
      it "works with keychain name" do
        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        keychain = File.expand_path('~/Library/Keychains/test.keychain')

        expect(result).to eq("security delete-keychain #{keychain}")
      end

      it "works with keychain name that contain spaces and `\"`" do
        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: '\" test \".keychain'
          })
        end").runner.execute(:test)

        keychain = File.expand_path(%(~/Library/Keychains/\\\"\\ test\\ \\\".keychain))

        expect(result).to eq %(security delete-keychain #{keychain})
      end

      it "works with absolute keychain path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            path: '/projects/test.keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq("security delete-keychain /projects/test.keychain")
      end
    end
  end
end
