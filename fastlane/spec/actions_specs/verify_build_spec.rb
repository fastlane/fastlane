describe Fastlane do
  describe Fastlane::FastFile do
    describe "verify_build" do
      let(:no_such_file) { "no-such-file.ipa" }
      let(:not_an_ipa) { File.expand_path("./fastlane_core/spec/fixtures/ipas/not-an-ipa.ipa") }
      let(:correctly_signed_ipa) { File.expand_path("./fastlane_core/spec/fixtures/ipas/very-capable-app.ipa") }
      let(:correctly_signed_ipa_with_spaces) { File.expand_path("./fastlane_core/spec/fixtures/ipas/very capable app.ipa") }
      # The .app fixtures are committed without their executable; the mac-only before(:context) builds and ad-hoc signs them.
      let(:correctly_signed_xcarchive) { File.join(@built_fixtures, "archives/very-capable-app.xcarchive") }
      let(:correctly_signed_xcarchive_with_spaces) { File.join(@built_fixtures, "archives/very capable app.xcarchive") }
      let(:correctly_signed_app) { File.join(correctly_signed_xcarchive, "Products/Applications/very-capable-app.app") }
      let(:correctly_signed_app_with_spaces) { File.join(correctly_signed_xcarchive_with_spaces, "Products/Applications/very capable app.app") }
      let(:incorrectly_signed_ipa) { File.expand_path("./fastlane_core/spec/fixtures/ipas/IncorrectlySigned.ipa") }
      let(:ipa_with_no_app) { File.expand_path("./fastlane_core/spec/fixtures/ipas/no-app-bundle.ipa") }
      let(:simulator_app) { File.join(@built_fixtures, "bundles/simulator-app.app") }
      let(:not_an_app) { File.expand_path("./fastlane_core/spec/fixtures/bundles/not-an-app.txt") }
      let(:archive_with_no_app) { File.expand_path("./fastlane_core/spec/fixtures/archives/no-app-bundle.xcarchive") }
      let(:expected_title) { "Summary for verify_build #{Fastlane::VERSION}" }
      let(:expected_app_info) do
        {
          "bundle_identifier" => "org.fastlane.very-capable-app",
          "team_identifier" => "TestFixture",
          "app_name" => "very-capable-app",
          "provisioning_uuid" => "12345678-1234-1234-1234-123456789012",
          "team_name" => "TestFixture",
          "authority" => ["TestFixture"]
        }
      end
      # An ad-hoc signature has no Authority line.
      let(:expected_built_app_info) { expected_app_info.except("authority") }

      before(:each) do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = nil
        allow(FastlaneCore::UI).to receive(:success).with("Driving the lane 'test' 🚀")
      end

      if FastlaneCore::Helper.mac?
        # Copies the .app fixtures to a scratch directory, compiles an executable into each and ad-hoc signs it.
        # Ad-hoc, because a named identity needs a keychain in the user's search list, which parallel workers share.
        before(:context) do
          @built_fixtures = Dir.mktmpdir("verify_build")
          FileUtils.cp_r(Dir[File.expand_path("./fastlane_core/spec/fixtures/{archives,bundles}")], @built_fixtures)
          source = File.join(@built_fixtures, "main.c")
          File.write(source, "int main(void) { return 0; }\n")
          Dir["#{@built_fixtures}/**/*.app"].each do |app|
            executable = File.join(app, File.basename(app, ".app"))
            system("cc", "-o", executable, source, exception: true)
            system("codesign", "--force", "--sign", "-", app, exception: true)
          end
        end

        after(:context) do
          FileUtils.remove_entry(@built_fixtures)
        end

        it "uses the ipa output path from lane context" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = correctly_signed_ipa

          expect(FastlaneCore::PrintTable).to receive(:print_values).with(config: expected_app_info, title: expected_title)
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
            verify_build
          end").runner.execute(:test)
        end

        it "uses ipa set via ipa_path" do
          expect(FastlaneCore::PrintTable).to receive(:print_values).with(config: expected_app_info, title: expected_title)
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
            verify_build(
              ipa_path: '#{correctly_signed_ipa}'
            )
          end").runner.execute(:test)
        end

        it "uses ipa set via ipa_path that contains spaces" do
          expect(FastlaneCore::PrintTable).to receive(:print_values).with(config: expected_app_info, title: expected_title)
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
            verify_build(
              ipa_path: '#{correctly_signed_ipa_with_spaces}'
            )
          end").runner.execute(:test)
        end

        it "uses app bundle set via build_path" do
          expect(FastlaneCore::PrintTable).to receive(:print_values).with(config: expected_built_app_info, title: expected_title)
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
            verify_build(
              build_path: '#{correctly_signed_app}'
            )
          end").runner.execute(:test)
        end

        it "uses app bundle set via build_path that contains spaces" do
          expect(FastlaneCore::PrintTable).to receive(:print_values).with(config: expected_built_app_info, title: expected_title)
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
            verify_build(
              build_path: '#{correctly_signed_app_with_spaces}'
            )
          end").runner.execute(:test)
        end

        it "raises an error if app is built for iOS simulator" do
          expect(FastlaneCore::UI).to receive(:user_error!).with(/Unable to find embedded profile/).and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: '#{simulator_app}'
              )
            end").runner.execute(:test)
          end.to raise_error(/Unable to find embedded profile/)
        end

        it "uses xcarchive set via build_path" do
          expect(FastlaneCore::PrintTable).to receive(:print_values).with(config: expected_built_app_info, title: expected_title)
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
            verify_build(
              build_path: '#{correctly_signed_xcarchive}'
            )
          end").runner.execute(:test)
        end

        it "uses xcarchive set via build_path that contain spaces" do
          expect(FastlaneCore::PrintTable).to receive(:print_values).with(config: expected_built_app_info, title: expected_title)
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
            verify_build(
              build_path: '#{correctly_signed_xcarchive_with_spaces}'
            )
          end").runner.execute(:test)
        end
      end

      describe "gather_cert_info" do
        let(:authority) { "iPhone Distribution: Example (ABCDE12345)" }
        let(:codesign_output) do
          <<~OUTPUT
            Executable=/path/to/app.app/app
            Identifier=org.fastlane.app
            Authority=#{authority}
            Authority=Apple Worldwide Developer Relations Certification Authority
            Authority=Apple Root CA
            TeamIdentifier=ABCDE12345
          OUTPUT
        end

        before do
          # gather_cert_info checks $?, which a stubbed backtick leaves at the previous child's status.
          allow(Fastlane::Actions::VerifyBuildAction).to receive(:`).with("codesign -vv -d /path/to/app.app 2>&1") do
            system("exit 0") && codesign_output
          end
        end

        it "reads the identifier, team and authorities and derives the provisioning type" do
          expect(Fastlane::Actions::VerifyBuildAction.gather_cert_info("/path/to/app.app")).to eq({
            "bundle_identifier" => "org.fastlane.app",
            "team_identifier" => "ABCDE12345",
            "provisioning_type" => "distribution",
            "authority" => [
              "iPhone Distribution: Example (ABCDE12345)",
              "Apple Worldwide Developer Relations Certification Authority",
              "Apple Root CA"
            ]
          })
        end

        context "with a development certificate" do
          let(:authority) { "Apple Development: Example (ABCDE12345)" }

          it "derives a development provisioning type" do
            expect(Fastlane::Actions::VerifyBuildAction.gather_cert_info("/path/to/app.app")["provisioning_type"]).to eq("development")
          end
        end
      end

      describe "Conflicting options" do
        it "raises an error if both build_path and ipa_path options are specified" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unresolved conflict between options: 'build_path' and 'ipa_path'").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: 'path/to/build',
                ipa_path: 'path/to/ipa'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'build_path' and 'ipa_path'")
        end

        it "raises an error if both ipa_path and build_path options are specified" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unresolved conflict between options: 'ipa_path' and 'build_path'").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                ipa_path: 'path/to/ipa',
                build_path: 'path/to/build'
              )
            end").runner.execute(:test)
          end.to raise_error("Unresolved conflict between options: 'ipa_path' and 'build_path'")
        end
      end

      describe "Missing ipa file" do
        it "raises an error if ipa file path set via lane context does not exist" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = no_such_file

          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find file '#{no_such_file}'").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build
            end").runner.execute(:test)
          end.to raise_error("Unable to find file '#{no_such_file}'")
        end

        it "raises an error if specified ipa file does not exist" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find file '#{no_such_file}'").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                ipa_path: '#{no_such_file}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to find file '#{no_such_file}'")
        end

        it "ignores ipa path from lane context if custom ipa is specified" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = correctly_signed_ipa

          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find file '#{no_such_file}'").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                ipa_path: '#{no_such_file}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to find file '#{no_such_file}'")
        end
      end

      describe "Missing build file" do
        it "raises an error if specified build file does not exist" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find file '#{no_such_file}'").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: '#{no_such_file}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to find file '#{no_such_file}'")
        end

        it "ignores ipa path from lane context if custom build path is specified" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = correctly_signed_ipa

          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find file '#{no_such_file}'").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: '#{no_such_file}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to find file '#{no_such_file}'")
        end
      end

      describe "Invalid build file" do
        it "raises an error if ipa is not signed correctly" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to verify code signing").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: '#{incorrectly_signed_ipa}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to verify code signing")
        end

        it "raises an error if ipa is not a valid zip archive" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to unzip ipa").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                ipa_path: '#{not_an_ipa}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to unzip ipa")
        end

        it "raises an error if build path is not a valid app file" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to verify code signing").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: '#{not_an_app}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to verify code signing")
        end
      end

      describe "Missing app file" do
        it "raises an error if ipa_path does not contain an app file" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find app file").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                ipa_path: '#{ipa_with_no_app}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to find app file")
        end

        it "raises an error if build_path does not contain an app file" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find app file").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: '#{ipa_with_no_app}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to find app file")
        end

        it "raises an error if xcarchive does not contain an app file" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find app file").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                build_path: '#{archive_with_no_app}'
              )
            end").runner.execute(:test)
          end.to raise_error("Unable to find app file")
        end
      end
    end
  end
end
