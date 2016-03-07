describe Fastlane do
  describe Fastlane::FastFile do
    describe "Delete keychain Integration" do
      it "works with keychain name" do
        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq("security delete-keychain test.keychain")
      end

      it "works with keychain name that contain spaces or `\"`" do
        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: '\" test \".keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq %(security delete-keychain \\\"\\ test\\ \\\".keychain)
      end
    end
  end
end
