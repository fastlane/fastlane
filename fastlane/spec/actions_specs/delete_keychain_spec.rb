describe Fastlane do
  describe Fastlane::FastFile do
    describe "Delete keychain Integration" do
      before :each do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "works with keychain name found locally" do
        allow(File).to receive(:exist?).with(/test.keychain/).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        keychain = File.expand_path('test.keychain')

        expect(result).to eq("security delete-keychain #{keychain}")
      end

      it "works with keychain name found in ~/Library/Keychains" do
        allow(File).to receive(:exist?).with(/test.keychain/).and_return(false)
        allow(File).to receive(:exist?).with(%r{Library/Keychains/test.keychain}).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        keychain = File.expand_path('~/Library/Keychains/test.keychain')

        expect(result).to eq("security delete-keychain #{keychain}")
      end

      it "works with keychain name that contain spaces and `\"`" do
        allow(File).to receive(:exist?).with(/\" test \".keychain/).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: '\" test \".keychain'
          })
        end").runner.execute(:test)

        keychain = File.expand_path('\\"\\ test\\ \\".keychain')

        expect(result).to eq %(security delete-keychain #{keychain})
      end

      it "works with absolute keychain path" do
        allow(File).to receive(:exist?).with('/projects/test.keychain').and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            keychain_path: '/projects/test.keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq("security delete-keychain /projects/test.keychain")
      end

      it "shows an error message if the keychain can't be found" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            delete_keychain ({
              name: 'test.keychain'
            })
          end").runner.execute(:test)
        end.to raise_error(
          "Unable to find the specified keychain. Looked in:" \
          "\n\t#{File.expand_path('test.keychain')}" \
          "\n\t#{File.expand_path('~/Library/Keychains/test.keychain')}"
        )
      end

      it "shows an error message if neither :name nor :keychain_path is given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            delete_keychain
          end").runner.execute(:test)
        end.to raise_error('You either have to set :name or :keychain_path')
      end
    end
  end
end
