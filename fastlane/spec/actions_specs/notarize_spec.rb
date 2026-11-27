describe Fastlane do
  describe Fastlane::FastFile do
    describe "notarize" do
      let(:success_submit_response) do
        {
         'status': 'Accepted',
         'id': '1111-2222-3333-4444'
        }.to_json
      end
      let(:invalid_submit_response) do
        {
         'status': 'Invalid',
         'statusSummary': 'Archive contains critical validation errors',
         'id': '1111-2222-3333-4444'
        }.to_json
      end

      it "file at :api_key_path must exist" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            notarize(
              api_key_path: '/tmp/file_does_not_exist'
            )
          end").runner.execute(:test)
        end.to raise_error("API Key not found at '/tmp/file_does_not_exist'")
      end

      it "forbids to provide both :username and :api_key" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            notarize(
              username: 'myusername@example.com',
              api_key: {'anykey' => 'anyvalue'}
            )
          end").runner.execute(:test)
        end.to raise_error("Unresolved conflict between options: 'username' and 'api_key'")
      end

      it "forbids to provide both :username and :keychain_profile" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            notarize(
              username: 'myusername@example.com',
              keychain_profile: 'keychain profile name'
            )
          end").runner.execute(:test)
        end.to raise_error("Unresolved conflict between options: 'username' and 'keychain_profile'")
      end

      it "forbids to provide both :api_key and :keychain_profile" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            notarize(
              api_key: {'anykey' => 'anyvalue'},
              keychain_profile: 'keychain profile name'
            )
          end").runner.execute(:test)
        end.to raise_error("Unresolved conflict between options: 'api_key' and 'keychain_profile'")
      end

      context "with notary tool" do
        let(:package) { Tempfile.new('app.ipa.zip') }

        it "fails before running notarytool when no credentials are given" do
          allow(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).and_return(nil)
          expect(Fastlane::Actions).not_to receive(:sh)

          expect do
            Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}'
              )
            end").runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, /:keychain_profile, :api_key, :api_key_path or :username/)
        end

        context "with Apple ID" do
          let(:username) { 'myusername@example.com' }
          let(:asc_provider) { '123456789' }
          let(:app_specific_password) { 'secretpass' }

          it "successful" do
            stub_const('ENV', { "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password })

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --apple-id #{username} --password #{app_specific_password} --team-id #{asc_provider}", { error_callback: anything, log: false, separate_stderr: true }).and_return(success_submit_response)

            expect(Fastlane::Actions).to receive(:sh).with("xcrun stapler staple #{package.path}", { log: false })

            result = Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}',
                username: '#{username}',
                asc_provider: '#{asc_provider}',
              )
            end").runner.execute(:test)
          end

          it "successful with verbose option" do
            stub_const('ENV', { "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password })

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --apple-id #{username} --password #{app_specific_password} --team-id #{asc_provider} --verbose", { error_callback: anything, log: true, separate_stderr: true }).and_return(success_submit_response)

            expect(Fastlane::Actions).to receive(:sh).with("xcrun stapler staple #{package.path}", { log: true })

            result = Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}',
                username: '#{username}',
                asc_provider: '#{asc_provider}',
                verbose: true
              )
            end").runner.execute(:test)
          end

          it "successful with skip_stapling" do
            stub_const('ENV', { "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password })

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --apple-id #{username} --password #{app_specific_password} --team-id #{asc_provider}", { error_callback: anything, log: false, separate_stderr: true }).and_return(success_submit_response)

            expect(Fastlane::Actions).not_to receive(:sh).with("xcrun stapler staple #{package.path}", { log: false })

            result = Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}',
                username: '#{username}',
                asc_provider: '#{asc_provider}',
                skip_stapling: true
              )
            end").runner.execute(:test)
          end

          it "invalid" do
            stub_const('ENV', { "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password })

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --apple-id #{username} --password #{app_specific_password} --team-id #{asc_provider}", { error_callback: anything, log: false, separate_stderr: true }).and_return(invalid_submit_response)

            expect do
              result = Fastlane::FastFile.new.parse("lane :test do
                notarize(
                  package: '#{package.path}',
                  username: '#{username}',
                  asc_provider: '#{asc_provider}',
                )
              end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not notarize package. To see the error, please set 'print_log' to true.")
          end

          context "running notarytool", unless: FastlaneCore::Helper.windows? do
            # The commands run in a subprocess, so PATH must really change, not just ENV in Ruby
            def with_fake_xcrun(script, password: app_specific_password)
              Dir.mktmpdir("fl_spec_xcrun") do |bin_dir|
                File.write(File.join(bin_dir, "xcrun"), "#!/bin/sh\n#{script}")
                File.chmod(0o755, File.join(bin_dir, "xcrun"))
                allow(FastlaneCore::Helper).to receive(:sh_enabled?).and_return(true)
                FastlaneCore::Helper.with_env_values("PATH" => "#{bin_dir}:#{ENV['PATH']}", "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => password) do
                  yield(bin_dir)
                end
              end
            end

            it "staples when notarytool logs to stderr before its result" do
              # See fastlane#28817
              script = <<~SCRIPT
                [ "$1" = stapler ] && touch "$(dirname "$0")/stapled" && exit 0
                echo '2026-11-06 10:00:00.000 notarytool[123:456] Error: execSQLStatement:onConnection: - no such table: main.cfurl_cache_response' >&2
                echo '#{success_submit_response}'
              SCRIPT

              with_fake_xcrun(script) do |bin_dir|
                Fastlane::FastFile.new.parse("lane :test do
                  notarize(
                    package: '#{package.path}',
                    username: '#{username}',
                    asc_provider: '#{asc_provider}'
                  )
                end").runner.execute(:test)

                expect(File.exist?(File.join(bin_dir, "stapled"))).to be(true)
              end
            end

            it "fails with notarytool's message when it fails" do
              script = <<~SCRIPT
                echo "Error: Missing value for '--password <password>'" >&2
                exit 64
              SCRIPT

              with_fake_xcrun(script, password: "") do
                expect do
                  Fastlane::FastFile.new.parse("lane :test do
                    notarize(
                      package: '#{package.path}',
                      username: '#{username}',
                      asc_provider: '#{asc_provider}'
                    )
                  end").runner.execute(:test)
                end.to raise_error(FastlaneCore::Interface::FastlaneError, /Missing value for '--password <password>'/)
              end
            end
          end
        end

        context "with an App Store Connect API key" do
          let(:api_key) { double('token', key_id: 'KEYID', issuer_id: 'ISSUER') }
          let(:key_file) { Tempfile.new('key') }

          before do
            package # create it before Tempfile.new is stubbed
            allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(api_key)
            allow(api_key).to receive(:write_key_to_file)
            allow(Tempfile).to receive(:new).and_return(key_file)
          end

          it "uses the API key from the lane context when the Appfile sets :apple_id" do
            allow(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).and_call_original
            allow(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).with(:apple_id).and_return('myusername@example.com')
            Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY] = { key_id: 'KEYID' }

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --key #{key_file.path} --key-id KEYID --issuer ISSUER", { error_callback: anything, log: false, separate_stderr: true }).and_return(success_submit_response)

            expect(Fastlane::Actions).to receive(:sh).with("xcrun stapler staple #{package.path}", { log: false })

            Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}'
              )
            end").runner.execute(:test)
          end
        end

        context "with :keychain_profile" do
          let(:keychain_profile) { 'Keychain profile name' }
          let(:keychain_path) { '~/Library/My Keychains/name' }

          it "successful with specified :keychain_path" do
            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --keychain-profile #{keychain_profile.shellescape} --keychain #{File.expand_path(keychain_path).shellescape}", { error_callback: anything, log: false, separate_stderr: true }).and_return(success_submit_response)

            expect(Fastlane::Actions).to receive(:sh).with("xcrun stapler staple #{package.path}", { log: false })

            Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}',
                keychain_path: '#{keychain_path}',
                keychain_profile: '#{keychain_profile}'
              )
            end").runner.execute(:test)
          end

          it "raises when :keychain_path is given without :keychain_profile" do
            expect(Fastlane::Actions).not_to receive(:sh)

            expect do
              Fastlane::FastFile.new.parse("lane :test do
                notarize(
                  package: '#{package.path}',
                  keychain_path: '#{keychain_path}'
                )
              end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError, "The :keychain_path option can only be used together with :keychain_profile")
          end

          it "successful w/o specified :keychain_path" do
            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --keychain-profile #{keychain_profile.shellescape}", { error_callback: anything, log: false, separate_stderr: true }).and_return(success_submit_response)

            expect(Fastlane::Actions).to receive(:sh).with("xcrun stapler staple #{package.path}", { log: false })

            Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}',
                keychain_profile: '#{keychain_profile}'
              )
            end").runner.execute(:test)
          end

          it "uses :keychain_profile even if there is API key in a lane context" do
            Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_STORE_CONNECT_API_KEY] = { key_id: 'KEYID' }
            allow(Spaceship::ConnectAPI::Token).to receive(:from).and_return(double('token', key_id: 'KEYID', issuer_id: 'ISSUER'))

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --keychain-profile #{keychain_profile.shellescape}", { error_callback: anything, log: false, separate_stderr: true }).and_return(success_submit_response)

            expect(Fastlane::Actions).to receive(:sh).with("xcrun stapler staple #{package.path}", { log: false })

            Fastlane::FastFile.new.parse("lane :test do
              notarize(
                package: '#{package.path}',
                keychain_profile: '#{keychain_profile}'
              )
            end").runner.execute(:test)
          end
        end

      end
    end
  end
end
