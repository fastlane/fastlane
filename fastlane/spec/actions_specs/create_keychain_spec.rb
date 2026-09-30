describe Fastlane do
  describe Fastlane::FastFile do
    describe "Create keychain Integration" do
      let(:login) { File.expand_path('~/Library/Keychains/login.keychain-db') }
      let(:test_keychain) { File.expand_path('~/Library/Keychains/test.keychain') }
      let(:calls) { [] }

      # Records what the action asks of the security gem, and never runs `security`.
      before do
        allow(Fastlane::Actions::CreateKeychainAction).to receive(:resolved_keychain_path).and_return(nil, test_keychain)
        allow(Security::Keychain).to receive(:create) { |path, password| calls << [:create, path, password] }
        allow(Security::Keychain).to receive(:list).with(:user).and_return([Security::Keychain.new(login)])
        allow(Security::Keychain).to receive(:default_keychain).and_return(Security::Keychain.new(login))
        allow(Security::Keychain).to receive(:set_default_keychain) { |keychain| calls << [:default, keychain.filename] }
        allow(Security::Keychain).to receive(:set_search_list) { |keychains| calls << [:search_list, keychains] }
        allow_any_instance_of(Security::Keychain).to receive(:unlock) { |keychain, password| calls << [:unlock, keychain.filename, password] }
        allow_any_instance_of(Security::Keychain).to receive(:update_settings) { |keychain, **settings| calls << [:settings, keychain.filename, settings] }
      end

      def create_keychain(options)
        Fastlane::FastFile.new.parse("lane :test do
          create_keychain(#{options})
        end").runner.execute(:test)
      end

      context "with name and password options" do
        it "creates the keychain, sets its settings and adds it to the search list" do
          create_keychain("name: 'test.keychain', password: 'testpassword'")

          expect(calls).to eq([
                                [:create, test_keychain, 'testpassword'],
                                [:settings, test_keychain, { timeout: 300, lock_when_sleeping: false, lock_after_timeout: false }],
                                [:search_list, [login, test_keychain]]
                              ])
        end

        it "only sets the settings of a keychain that already exists and is in the search list" do
          allow(Fastlane::Actions::CreateKeychainAction).to receive(:resolved_keychain_path).and_return(test_keychain)
          allow(Security::Keychain).to receive(:list).with(:user).and_return([Security::Keychain.new(login), Security::Keychain.new(test_keychain)])

          create_keychain("name: 'test.keychain', password: 'testpassword'")

          expect(calls).to eq([[:settings, test_keychain, { timeout: 300, lock_when_sleeping: false, lock_after_timeout: false }]])
        end

        it "passes names and passwords containing spaces or quotes as they are" do
          create_keychain("name: 'my test.keychain', password: '\"test password\"', add_to_search_list: false")

          expect(calls.first).to eq([:create, File.expand_path('~/Library/Keychains/my test.keychain'), '"test password"'])
        end

        it "passes the keychain settings" do
          create_keychain("name: 'test.keychain', password: 'testpassword', timeout: 600, lock_when_sleeps: true, lock_after_timeout: true, add_to_search_list: false")

          expect(calls.last).to eq([:settings, test_keychain, { timeout: 600, lock_when_sleeping: true, lock_after_timeout: true }])
        end

        it "makes it the default keychain, remembering the original one" do
          create_keychain("name: 'test.keychain', password: 'testpassword', default_keychain: true, add_to_search_list: false")

          expect(calls[1]).to eq([:default, test_keychain])
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::ORIGINAL_DEFAULT_KEYCHAIN]).to eq(login)
        end

        it "unlocks it" do
          create_keychain("name: 'test.keychain', password: 'testpassword', unlock: true, add_to_search_list: false")

          expect(calls[1]).to eq([:unlock, test_keychain, 'testpassword'])
        end

        it "never times out with 'timeout: 0'" do
          create_keychain("name: 'test.keychain', password: 'testpassword', timeout: 0, add_to_search_list: false")

          expect(calls.last).to eq([:settings, test_keychain, { timeout: nil, lock_when_sleeping: false, lock_after_timeout: false }])
        end

        it "sets the correct keychain path" do
          create_keychain("name: 'test.keychain', password: 'testpassword', add_to_search_list: false")

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::KEYCHAIN_PATH]).to eq('~/Library/Keychains/test.keychain')
        end

        it "reports a keychain that cannot be created" do
          allow(Security::Keychain).to receive(:create).and_raise(Security::Error.new(48, "security: SecKeychainCreate: A keychain with the same name already exists.\n"))

          expect { create_keychain("name: 'test.keychain', password: 'testpassword'") }
            .to raise_error(FastlaneCore::Interface::FastlaneError, %r{Could not create keychain '~/Library/Keychains/test.keychain': .*already exists})
        end

        it "reports a keychain that cannot be unlocked" do
          allow_any_instance_of(Security::Keychain).to receive(:unlock).and_return(false)

          expect { create_keychain("name: 'test.keychain', password: 'testpassword', unlock: true") }
            .to raise_error(FastlaneCore::Interface::FastlaneError, "Could not unlock keychain '~/Library/Keychains/test.keychain'")
        end

        it "reports settings that cannot be changed" do
          allow_any_instance_of(Security::Keychain).to receive(:update_settings).and_return(false)

          expect { create_keychain("name: 'test.keychain', password: 'testpassword'") }
            .to raise_error(FastlaneCore::Interface::FastlaneError, "Could not change the settings of keychain '~/Library/Keychains/test.keychain'")
        end
      end

      context "with path and password options" do
        it "successfully creates the keychain" do
          create_keychain("path: '/tmp/test.keychain', password: 'testpassword', default_keychain: true, unlock: true, add_to_search_list: false")

          expect(calls.map(&:first)).to eq([:create, :default, :unlock, :settings])
          expect(calls.map { |call| call[1] }.uniq).to eq([File.expand_path('/tmp/test.keychain')])
        end

        it "sets the correct keychain path" do
          create_keychain("path: '/tmp/test.keychain', password: 'testpassword', add_to_search_list: false")

          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::KEYCHAIN_PATH]).to eq('/tmp/test.keychain')
        end
      end
    end
  end
end
