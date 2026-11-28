describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Project Provisioning" do
      let(:fixtures_path) { "./fastlane/spec/fixtures" }
      let(:xcodeproj) { File.absolute_path(File.join(fixtures_path, 'xcodeproj', 'bundle.xcodeproj')) }
      let(:profile_path) { File.absolute_path(File.join(fixtures_path, 'profiles', 'test.mobileprovision')) }
      describe "target_filter" do
        before do
          allow(Fastlane::Actions::UpdateProjectProvisioningAction).to receive(:run)
        end

        context 'with String' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    target_filter: 'Name'
                })
              end").runner.execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with Regexp' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    target_filter: /Name/
                })
              end").runner.execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with other type' do
          it 'should be invalid' do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    target_filter: 1
                })
              end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError)
          end
        end
      end

      describe "build_configuration" do
        before do
          allow(Fastlane::Actions::UpdateProjectProvisioningAction).to receive(:run)
        end

        context 'with String' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    build_configuration: 'Debug'
                })
              end").runner.execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with Regexp' do
          it 'should be valid' do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    build_configuration: /Debug/
                })
              end").runner.execute(:test)
            end.not_to(raise_error)
          end
        end

        context 'with other type' do
          it 'should be invalid' do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                  update_project_provisioning ({
                    xcodeproj: '#{xcodeproj}',
                    profile: '#{profile_path}',
                    build_configuration: 1
                })
              end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError)
          end
        end
      end

      describe "root certificates" do
        let(:action) { Fastlane::Actions::UpdateProjectProvisioningAction }
        let(:ca_key) { OpenSSL::PKey::RSA.new(2048) }
        let(:ca) do
          cert = OpenSSL::X509::Certificate.new
          cert.version = 2
          cert.serial = 1
          cert.subject = cert.issuer = OpenSSL::X509::Name.parse("/CN=Test Root")
          cert.public_key = ca_key.public_key
          cert.not_before = Time.now - 60
          cert.not_after = Time.now + 3600
          cert.sign(ca_key, OpenSSL::Digest.new('SHA256'))
          cert
        end
        # The CRLF breaks a profile read in text mode on Windows.
        let(:plist) { Plist::Emit.dump({ "UUID" => "1234-ABCD", "Name" => "Test Profile", "Note" => "line\r\nline" }) }
        let(:shipped_certificates) { action::ROOT_CERTIFICATE_PATHS.map { |path| File.binread(path) } }

        around do |example|
          Dir.mktmpdir("update_project_provisioning_spec-") do |dir|
            @dir = dir
            FastlaneSpec::Env.with_env_values('TMPDIR' => dir, 'FL_PROJECT_PROVISIONING_CERTIFICATE_PATH' => nil, 'FASTLANE_LANE_NAME' => nil) { example.run }
          end
        end

        def write(name, content)
          File.join(@dir, name).tap { |path| File.binwrite(path, content) }
        end

        def run_action(certificate: nil)
          FileUtils.cp_r(xcodeproj, @dir)
          profile = write("test.mobileprovision", OpenSSL::PKCS7.sign(ca, ca_key, plist, [], OpenSSL::PKCS7::BINARY).to_der)
          certificate_option = certificate ? "certificate: '#{certificate}'," : ""
          Fastlane::FastFile.new.parse("lane :test do
            update_project_provisioning(
              xcodeproj: '#{File.join(@dir, File.basename(xcodeproj))}',
              #{certificate_option}
              profile: '#{profile}'
            )
          end").runner.execute(:test)
        end

        it "ships Apple Root CA and Apple Root CA - G3" do
          fingerprints = action::ROOT_CERTIFICATE_PATHS.map { |path| Digest::SHA256.file(path).hexdigest }

          expect(fingerprints).to eq([
                                       "b0b1730ecbc7ff4505142c49f1295e6eda6bcaed7e2c68c5be91b5a11001f024",
                                       "63343abfb89a6a03ebb57e9b3f5fa7be7c4f5c756f3017b3a8c488c3653e9179"
                                     ])
        end

        it "uses the shipped certificates when no certificate is given" do
          expect(action.root_certificates(nil).map(&:to_der)).to eq(shipped_certificates)
        end

        it "uses the shipped certificates, and warns, when the given certificate does not exist" do
          path = File.join(@dir, "missing.cer")
          expect(FastlaneCore::UI).to receive(:important).with(/No certificate at '#{Regexp.escape(path)}'.*Remove the `certificate` option/)

          expect(action.root_certificates(path).map(&:to_der)).to eq(shipped_certificates)
        end

        it "does not warn when no certificate is given" do
          expect(FastlaneCore::UI).not_to receive(:important)

          action.root_certificates(nil)
        end

        it "adds the given certificate to the shipped ones when it exists" do
          path = write("root.cer", ca.to_der)

          expect(action.root_certificates(path).map(&:to_der)).to eq(shipped_certificates + [ca.to_der])
        end

        it "verifies the profile with the given certificate and updates the project" do
          run_action(certificate: write("root.cer", ca.to_der))

          project = Xcodeproj::Project.open(File.join(@dir, File.basename(xcodeproj)))
          settings = project.targets.flat_map(&:build_configurations).map(&:build_settings)
          expect(settings).to all(include("PROVISIONING_PROFILE" => "1234-ABCD", "PROVISIONING_PROFILE_SPECIFIER" => "Test Profile"))
        end

        it "rejects a profile Apple did not sign, without downloading anything, when no certificate is given" do
          expect { run_action }.to raise_error(FastlaneCore::Interface::FastlaneCrash, /Profile could not be verified/)
          expect(a_request(:any, /apple\.com/)).not_to have_been_made
        end
      end

      describe "check_verify" do
        let(:p7) { double('p7') }

        context 'pass' do
          it 'has data and nil error_string' do
            allow(p7).to receive(:data).and_return("data")
            allow(p7).to receive(:error_string).and_return(nil)

            Fastlane::Actions::UpdateProjectProvisioningAction.check_verify!(p7)
          end

          it 'has data and empty error_string' do
            allow(p7).to receive(:data).and_return("data")
            allow(p7).to receive(:error_string).and_return("")

            Fastlane::Actions::UpdateProjectProvisioningAction.check_verify!(p7)
          end
        end

        context 'fail' do
          it 'has no data' do
            allow(p7).to receive(:data).and_return(nil)
            allow(p7).to receive(:error_string).and_return("Some error")

            expect do
              Fastlane::Actions::UpdateProjectProvisioningAction.check_verify!(p7)
            end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
          end

          it 'has empty data' do
            allow(p7).to receive(:data).and_return("")
            allow(p7).to receive(:error_string).and_return("Some error")

            expect do
              Fastlane::Actions::UpdateProjectProvisioningAction.check_verify!(p7)
            end.to raise_error(FastlaneCore::Interface::FastlaneCrash)
          end
        end
      end
    end
  end
end
