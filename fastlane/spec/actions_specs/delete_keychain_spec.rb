describe Fastlane do
  describe Fastlane::FastFile do
    describe "Delete keychain Integration" do
      let(:deleted) { [] }

      # Records what the action asks of the security gem, and never runs `security`.
      before :each do
        allow(File).to receive(:file?).and_return(false)
        allow_any_instance_of(Security::Keychain).to receive(:delete) { |keychain| deleted << keychain.filename }
      end

      it "works with keychain name found locally" do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        keychain = File.expand_path('test.keychain')
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with(keychain).and_return(true)

        Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        expect(deleted).to eq([keychain])
      end

      it "works with keychain name found in ~/Library/Keychains" do
        keychain = File.expand_path('~/Library/Keychains/test.keychain')
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with(keychain).and_return(true)

        Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        expect(deleted).to eq([keychain])
      end

      it "works with keychain name found in ~/Library/Keychains with -db" do
        keychain = File.expand_path('~/Library/Keychains/test.keychain-db')
        allow(File).to receive(:file?).and_return(false)
        allow(File).to receive(:file?).with(keychain).and_return(true)

        Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: 'test.keychain'
          })
        end").runner.execute(:test)

        expect(deleted).to eq([keychain])
      end

      it "works with keychain name that contain spaces and `\"`" do
        keychain = File.expand_path('" test ".keychain')
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        allow(File).to receive(:file?).with(keychain).and_return(true)

        Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            name: '\" test \".keychain'
          })
        end").runner.execute(:test)

        expect(deleted).to eq([keychain])
      end

      it "works with absolute keychain path" do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with('/projects/test.keychain').and_return(true)
        allow(File).to receive(:file?).with('/projects/test.keychain').and_return(true)

        Fastlane::FastFile.new.parse("lane :test do
          delete_keychain ({
            keychain_path: '/projects/test.keychain'
          })
        end").runner.execute(:test)

        expect(deleted).to eq(["/projects/test.keychain"])
      end

      it "restores the default keychain create_keychain replaced" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN] = "/a b/login.keychain-db"
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/projects/test.keychain').and_return(true)
        expect(Security::Keychain).to receive(:set_default_keychain).with("/a b/login.keychain-db").and_return(true)

        Fastlane::FastFile.new.parse("lane :test do
          delete_keychain(keychain_path: '/projects/test.keychain')
        end").runner.execute(:test)

        expect(deleted).to eq(["/projects/test.keychain"])
      ensure
        Fastlane::Actions.lane_context.delete(Fastlane::Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN)
      end

      it "reports a keychain that cannot be deleted" do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with('/projects/test.keychain').and_return(true)
        allow_any_instance_of(Security::Keychain).to receive(:delete).and_return(false)

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            delete_keychain(keychain_path: '/projects/test.keychain')
          end").runner.execute(:test)
        end.to raise_error("Could not delete keychain '/projects/test.keychain'")
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
