describe Fastlane do
  describe Fastlane::FastFile do
    describe "Delete keychain Integration" do
      before :each do
        allow(File).to receive(:file?).and_return(false)
      end

      it "works with keychain name found locally" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        keychain = File.expand_path('test.keychain')
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with(keychain).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq("security delete-keychain #{keychain}")
      end

      it "works with keychain name found in ~/Library/Keychains" do
        keychain = File.expand_path('~/Library/Keychains/test.keychain')
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with(keychain).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq("security delete-keychain #{keychain}")
      end

      it "works with keychain name found in ~/Library/Keychains with -db" do
        keychain = File.expand_path('~/Library/Keychains/test.keychain-db')
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with(keychain).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq("security delete-keychain #{keychain}")
      end

      it "works with keychain name that contain spaces and `\"`" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        allow(File).to receive(:file?).with(File.expand_path('" test ".keychain')).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: '\" test \".keychain'
          })
        end").runner.execute(:test)

        keychain = File.expand_path('\\"\\ test\\ \\".keychain')
        expect(result).to eq(%(security delete-keychain #{keychain}))
      end

      it "works with absolute keychain path" do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with('/projects/test.keychain').and_return(true)
        allow(File).to receive(:file?).with('/projects/test.keychain').and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            keychain_path: '/projects/test.keychain'
          })
        end").runner.execute(:test)

        expect(result).to eq("security delete-keychain /projects/test.keychain")
      end

      it "shows an error message if the keychain can't be found" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            delete_keychain ({
              name: 'test.keychain'
            })
          end").runner.execute(:test)
        end.to raise_error(/Could not locate the provided keychain/)
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
