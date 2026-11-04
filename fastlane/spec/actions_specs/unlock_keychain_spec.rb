describe Fastlane do
  describe Fastlane::FastFile do
    describe "Unlock keychain Integration" do
      # Keep the Tempfile, not only its path: an unreferenced one is deleted when the GC finalises it. See fastlane#30184.
      let(:keychain_file) { Tempfile.new('foo') }
      let(:keychain_path) { keychain_file.path }
      let(:login) { File.expand_path('~/Library/Keychains/login.keychain-db') }
      let(:calls) { [] }

      # Records what the action asks of the security gem, and never runs `security`.
      before do
        allow(Security::Keychain).to receive(:list).with(:user).and_return([Security::Keychain.new(login)])
        allow(Security::Keychain).to receive(:default_keychain).and_return(Security::Keychain.new(login))
        allow(Security::Keychain).to receive(:set_default_keychain) { |keychain| calls << [:default, keychain] }
        allow(Security::Keychain).to receive(:set_search_list) { |keychains| calls << [:search_list, keychains] }
        allow_any_instance_of(Security::Keychain).to receive(:unlock) { |keychain, password| calls << [:unlock, keychain.filename, password] }
        allow_any_instance_of(Security::Keychain).to receive(:update_settings) { |keychain, **settings| calls << [:settings, keychain.filename, settings] }
      end

      def unlock_keychain(options = "")
        Fastlane::FastFile.new.parse("lane :test do
          unlock_keychain(path: '#{keychain_path}', password: 'testpassword'#{options})
        end").runner.execute(:test)
      end

      it "adds it to the search list, unlocks it and stops it locking" do
        unlock_keychain

        expect(calls).to eq([
                              [:search_list, [login, keychain_path]],
                              [:unlock, keychain_path, 'testpassword'],
                              [:settings, keychain_path, {}]
                            ])
      end

      it "leaves the search list alone when it is already there" do
        allow(Security::Keychain).to receive(:list).with(:user).and_return([Security::Keychain.new(login), Security::Keychain.new(keychain_path)])

        unlock_keychain

        expect(calls.map(&:first)).to eq([:unlock, :settings])
      end

      it "doesn't add keychain to search list" do
        unlock_keychain(", add_to_search_list: false")

        expect(calls.map(&:first)).to eq([:unlock, :settings])
      end

      it "replaces the search list, remembering the original default keychain" do
        unlock_keychain(", add_to_search_list: :replace")

        expect(calls.first).to eq([:search_list, [keychain_path]])
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN]).to eq(login)
      end

      it "replaces the search list when there is no default keychain" do
        allow(Security::Keychain).to receive(:default_keychain).and_raise(Security::Error.new(50, "security: SecKeychainCopyDefault: A default keychain could not be found.\n"))

        unlock_keychain(", add_to_search_list: :replace")

        expect(calls.first).to eq([:search_list, [keychain_path]])
      end

      it "set default keychain" do
        unlock_keychain(", set_default: true")

        expect(calls.map(&:first)).to eq([:search_list, :default, :unlock, :settings])
        expect(calls[1]).to eq([:default, keychain_path])
      end

      it "reports a keychain that cannot be unlocked" do
        allow_any_instance_of(Security::Keychain).to receive(:unlock).and_return(false)

        expect { unlock_keychain }.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not unlock keychain '#{keychain_path}'")
      end

      it "reports a search list that cannot be changed" do
        allow(Security::Keychain).to receive(:set_search_list).and_return(false)

        expect { unlock_keychain }.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not add '#{keychain_path}' to the keychain search list")
      end
    end
  end
end
