describe Fastlane do
  describe Fastlane::FastFile do
    describe "Crashlytics Integration" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
        ENV.delete("CRASHLYTICS_API_TOKEN")
        ENV.delete("CRASHLYTICS_BUILD_SECRET")
        ENV.delete("CRASHLYTICS_FRAMEWORK_PATH")
        @crashlytics_bundle = "Crashlytics.framework/submit"
      end

      describe "Android" do
        describe "Valid parameters" do
          it "works with valid parameters" do
            command = Fastlane::FastFile.new.parse('lane :test do
              crashlytics(
                crashlytics_path: "./fastlane/spec/fixtures/fastfiles/Fastfile1",
                api_token: "api_token",
                build_secret: "build_secret",
                apk_path: "./fastlane/spec/fixtures/fastfiles/Fastfile2",
                emails: ["email1@krausefx.com", "email2@krausefx.com"],
                groups: "testgroup",
                notes: "Such notes, very release"
              )
            end').runner.execute(:test)
            ["java",
             "-jar /",
             "-androidRes .",
             "-apiKey api_token",
             "-apiSecret build_secret",
             "-uploadDist '/",
             "-betaDistributionReleaseNotesFilePath '/",
             "-betaDistributionEmails 'email1@krausefx.com,email2@krausefx.com'",
             "-betaDistributionGroupAliases 'testgroup'",
             "-betaDistributionNotifications true"].each do |to_be|
              expect(command.join(" ")).to include(to_be)
            end

            # These 2 parameters are temporary
            # "-androidManifest '/var/folders/dh/6sxzb7_n37nb8s8pbbk_wc0c0000gn/T/xml20151005-29563-m97zs2'",
            # "-betaDistributionReleaseNotesFilePath '/var/folders/dh/6sxzb7_n37nb8s8pbbk_wc0c0000gn/T/changelog20151005-29563-1o3uf3m'",
            expect(command.join(" ")).to include("-betaDistributionReleaseNotesFilePath")
            expect(command.join(" ")).to include("-androidManifest")
          end
        end

        it "hides sensitive parameters" do
          with_verbose(true) do
            expect(UI).to receive(:verbose) do |message|
              expect(message).to_not(include('PEANUTS'))
              expect(message).to_not(include('MAJOR_KEY'))

              expect(message).to include('[[BUILD_SECRET]]')
              expect(message).to include('[[API_TOKEN')
            end

            Fastlane::FastFile.new.parse('lane :test do
            crashlytics(
              crashlytics_path: "./fastlane/spec/fixtures/fastfiles/Fastfile1",
              api_token: "PEANUTS",
              build_secret: "MAJOR_KEY",
              apk_path: "./fastlane/spec/fixtures/fastfiles/Fastfile2",
              emails: ["email1@krausefx.com", "email2@krausefx.com"],
              groups: "testgroup",
              notes: "Such notes, very release"
              )
            end').runner.execute(:test)
          end
        end
      end

      describe "iOS" do
        describe "Valid Parameters" do
          it "works with valid parameters" do
            command = Fastlane::FastFile.new.parse("lane :test do
              crashlytics({
                crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                api_token: 'wadus',
                build_secret: 'secret',
                ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
              })
            end").runner.execute(:test)

            expect(command).to eq([
                                    @crashlytics_bundle,
                                    "wadus",
                                    "secret",
                                    "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-notifications YES",
                                    "-debug NO"
                                  ])
          end

          it "hides sensitive parameters" do
            with_verbose(true) do
              expect(UI).to receive(:verbose) do |message|
                expect(message).to_not(include('PEANUTS'))
                expect(message).to_not(include('MAJOR_KEY'))

                expect(message).to include('[[BUILD_SECRET]]')
                expect(message).to include('[[API_TOKEN')
              end
              Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  api_token: 'MAJOR_KEY',
                  build_secret: 'PEANUTS',
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
                })
              end").runner.execute(:test)
            end
          end

          it "works automatically stores the notes in a file if given" do
            command = Fastlane::FastFile.new.parse("lane :test do
              crashlytics({
                crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                api_token: 'wadus',
                build_secret: 'secret',
                ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                notes: 'Yooo, hi!'
              })
            end").runner.execute(:test)

            [@crashlytics_bundle,
             "wadus",
             "secret",
             "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
             "-notifications YES",
             "-debug NO"].each do |to_be|
              expect(command).to include(to_be)
            end
          end

          it "works when using environment variables in place of parameters" do
            ENV["CRASHLYTICS_API_TOKEN"] = "wadus"
            ENV["CRASHLYTICS_BUILD_SECRET"] = "secret"
            ENV["CRASHLYTICS_FRAMEWORK_PATH"] = "./fastlane/spec/fixtures/fastfiles/Fastfile1"

            command = Fastlane::FastFile.new.parse("lane :test do
              crashlytics({
                ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
              })
            end").runner.execute(:test)

            expect(command).to eq([
                                    @crashlytics_bundle,
                                    "wadus",
                                    "secret",
                                    "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-notifications YES",
                                    "-debug NO"
                                  ])
          end

          it "works when using TrueClass variable in place of notifications parameter" do
            ENV["CRASHLYTICS_API_TOKEN"] = "wadus"
            ENV["CRASHLYTICS_BUILD_SECRET"] = "secret"
            ENV["CRASHLYTICS_FRAMEWORK_PATH"] = "./fastlane/spec/fixtures/fastfiles/Fastfile1"

            command = Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  notifications: true
                })
              end").runner.execute(:test)

            expect(command).to eq([
                                    @crashlytics_bundle,
                                    "wadus",
                                    "secret",
                                    "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-notifications YES",
                                    "-debug NO"
                                  ])
          end

          it "works when using 'false' String variable in place of notifications parameter" do
            ENV["CRASHLYTICS_API_TOKEN"] = "wadus"
            ENV["CRASHLYTICS_BUILD_SECRET"] = "secret"
            ENV["CRASHLYTICS_FRAMEWORK_PATH"] = "./fastlane/spec/fixtures/fastfiles/Fastfile1"

            command = Fastlane::FastFile.new.parse("lane :test do
              crashlytics({
                ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                notifications: 'false'
              })
            end").runner.execute(:test)

            expect(command).to eq([
                                    @crashlytics_bundle,
                                    "wadus",
                                    "secret",
                                    "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-notifications NO",
                                    "-debug NO"
                                  ])
          end

          it "works when using TrueClass variable in place of debug parameter" do
            ENV["CRASHLYTICS_API_TOKEN"] = "wadus"
            ENV["CRASHLYTICS_BUILD_SECRET"] = "secret"
            ENV["CRASHLYTICS_FRAMEWORK_PATH"] = "./fastlane/spec/fixtures/fastfiles/Fastfile1"

            command = Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  debug: 'true'
                })
              end").runner.execute(:test)

            expect(command).to eq([
                                    @crashlytics_bundle,
                                    "wadus",
                                    "secret",
                                    "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-notifications YES",
                                    "-debug YES"
                                  ])
          end

          it "works when using 'false' String variable in place of debug parameter" do
            ENV["CRASHLYTICS_API_TOKEN"] = "wadus"
            ENV["CRASHLYTICS_BUILD_SECRET"] = "secret"
            ENV["CRASHLYTICS_FRAMEWORK_PATH"] = "./fastlane/spec/fixtures/fastfiles/Fastfile1"

            command = Fastlane::FastFile.new.parse("lane :test do
              crashlytics({
                ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                notifications: 'false',
                debug: 'false'
              })
            end").runner.execute(:test)

            expect(command).to eq([
                                    @crashlytics_bundle,
                                    "wadus",
                                    "secret",
                                    "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-notifications NO",
                                    "-debug NO"
                                  ])
          end

          it "works when filling out all the parameters" do
            ENV["CRASHLYTICS_API_TOKEN"] = "wadus"
            ENV["CRASHLYTICS_BUILD_SECRET"] = "secret"

            command = Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  notes_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  groups: ['groups', '123'],
                  emails: ['email1', 'email2'],
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  notifications: false
                })
              end").runner.execute(:test)

            expect(command).to eq([
                                    @crashlytics_bundle,
                                    "wadus",
                                    "secret",
                                    "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-emails 'email1,email2'",
                                    "-notesPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                    "-groupAliases 'groups,123'",
                                    "-notifications NO",
                                    "-debug NO"
                                  ])
          end
        end

        describe "Invalid Parameters" do
          it "raises an error if no crashlytics path was given" do
            expect(Fastlane::Helper::CrashlyticsHelper).to receive(:discover_default_crashlytics_path).and_return(nil)
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  api_token: 'wadus',
                  build_secret: 'wadus',
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
                })
              end").runner.execute(:test)
            end.to raise_error("No value found for 'crashlytics_path'")
          end

          it "raises an error if the given crashlytics path was not found" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  crashlytics_path: './fastlane/wadus',
                  api_token: 'wadus',
                  build_secret: 'wadus',
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
                })
              end").runner.execute(:test)
            end.to raise_error(%r{Couldn't find crashlytics at path .*fastlane/wadus})
          end

          it "raises an error if no api token was given" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  build_secret: 'wadus',
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
                })
              end").runner.execute(:test)
            end.to raise_error("No API token for Crashlytics given, pass using `api_token: 'token'`")
          end

          it "raises an error if no build secret was given" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  api_token: 'wadus',
                  ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
                })
              end").runner.execute(:test)
            end.to raise_error("No build secret for Crashlytics given, pass using `build_secret: 'secret'`")
          end

          it "raises an error if no ipa path was given" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  api_token: 'wadus',
                  build_secret: 'wadus'
                })
              end").runner.execute(:test)
            end.to raise_error("You have to either pass an ipa or an apk file to the Crashlytics action")
          end

          it "raises an error if the given ipa path was not found" do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                crashlytics({
                  crashlytics_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                  api_token: 'wadus',
                  build_secret: 'wadus',
                  ipa_path: './fastlane/wadus'
                })
              end").runner.execute(:test)
            end.to raise_error("Couldn't find ipa file at path './fastlane/wadus'")
          end
        end
      end
    end
  end
end
