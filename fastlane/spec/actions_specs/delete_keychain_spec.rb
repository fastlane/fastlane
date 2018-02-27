describe Fastlane do
  describe Fastlane::FastFile do
    describe "Delete keychain Integration" do
      it "works with keychain name found locally" do
        keychain = File.expand_path('test.keychain')
        keychains = double("keychains")
        allow(keychains).to receive(:split).and_return([keychain])
        allow(Fastlane::Actions).to receive(:sh).with("security list-keychains", log: false).and_return(keychains)
        allow(Fastlane::Actions).to receive(:sh).with("security delete-keychain #{keychain}", log: false).and_call_original
        allow(FastlaneCore::Helper).to receive(:keychain_path).with('test.keychain').and_return(keychain)
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with(keychain).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain',
            throw_error:false
          })
        end").runner.execute(:test)

        expect(Fastlane::Actions).to have_received(:sh).with("security delete-keychain #{keychain}", log: false)
      end

      it "works with keychain name found in ~/Library/Keychains" do
        keychain = File.expand_path('~/Library/Keychains/test.keychain')
        keychains = double("keychains")
        allow(keychains).to receive(:split).and_return([keychain])
        allow(Fastlane::Actions).to receive(:sh).with("security list-keychains", log: false).and_return(keychains)
        allow(Fastlane::Actions).to receive(:sh).with("security delete-keychain #{keychain}", log: false).and_call_original
        allow(FastlaneCore::Helper).to receive(:keychain_path).with('test.keychain').and_return(keychain)
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with(keychain).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain',
            throw_error:false
          })
        end").runner.execute(:test)

        expect(Fastlane::Actions).to have_received(:sh).with("security delete-keychain #{keychain}", log: false)
      end

      it "works with keychain name found in ~/Library/Keychains with -db" do
        keychain = File.expand_path('~/Library/Keychains/test.keychain-db')
        keychains = double("keychains")
        allow(keychains).to receive(:split).and_return([keychain])
        allow(Fastlane::Actions).to receive(:sh).with("security list-keychains", log: false).and_return(keychains)
        allow(Fastlane::Actions).to receive(:sh).with("security delete-keychain #{keychain}", log: false).and_call_original
        allow(FastlaneCore::Helper).to receive(:keychain_path).with('test.keychain').and_return(keychain)
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with(keychain).and_return(true)

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain',
            throw_error:false
          })
        end").runner.execute(:test)

        expect(Fastlane::Actions).to have_received(:sh).with("security delete-keychain #{keychain}", log: false)
      end

      it "works with absolute keychain path" do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with('/projects/test.keychain').and_return(true)
        allow(File).to receive(:file?).with('/projects/test.keychain').and_return(true)
        allow(Fastlane::Actions).to receive(:sh).with("security delete-keychain /projects/test.keychain", log: false).and_call_original

        result = Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            keychain_path: '/projects/test.keychain',
            throw_error:true
          })
        end").runner.execute(:test)

        expect(Fastlane::Actions).to have_received(:sh).with("security delete-keychain /projects/test.keychain", log: false)
      end

      it "shows an error message if the keychain can't be found" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            delete_keychain ({
              name: 'test.keychain',
              throw_error:true
            })
          end").runner.execute(:test)
        end.to raise_error('Unable to find the specified keychain.')
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
