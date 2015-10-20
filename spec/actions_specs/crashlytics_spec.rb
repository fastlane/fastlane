describe Fastlane do
  describe Fastlane::FastFile do
    describe "Crashlytics Integration" do
      before :each do
        ENV.delete "CRASHLYTICS_API_TOKEN"
        ENV.delete "CRASHLYTICS_BUILD_SECRET"
        ENV.delete "CRASHLYTICS_FRAMEWORK_PATH"
      end

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

          expect(command).to eq(["./fastlane/spec/fixtures/fastfiles/Fastfile1/submit",
                                 "wadus",
                                 "secret",
                                 "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                 "-notifications YES"
                                ])
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

          changelog_path = command.find { |a| a.include?("-notesPath") }.match(%r{'(\/tmp\/.*)'})[1]

          expect(command).to eq(["./fastlane/spec/fixtures/fastfiles/Fastfile1/submit",
                                 "wadus",
                                 "secret",
                                 "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
                                 "-notesPath '#{changelog_path}'",
                                 "-notifications YES"
                                ])

          expect(File.read(changelog_path)).to eq("Yooo, hi!")
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
            "./fastlane/spec/fixtures/fastfiles/Fastfile1/submit",
            "wadus",
            "secret",
            "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
            "-notifications YES"
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
            "./fastlane/spec/fixtures/fastfiles/Fastfile1/submit",
            "wadus",
            "secret",
            "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
            "-notifications YES"
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
            "./fastlane/spec/fixtures/fastfiles/Fastfile1/submit",
            "wadus",
            "secret",
            "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
            "-notifications NO"
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
            "./fastlane/spec/fixtures/fastfiles/Fastfile1/submit",
            "wadus",
            "secret",
            "-ipaPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
            "-emails 'email1,email2'",
            "-notesPath './fastlane/spec/fixtures/fastfiles/Fastfile1'",
            "-groupAliases 'groups,123'",
            "-notifications NO"])
        end
      end

      describe "Invalid Parameters" do
        it "raises an error if no parameters were given" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              crashlytics()
            end").runner.execute(:test)
          end.to raise_error("No Crashlytics path given or found, pass using `crashlytics_path: 'path'`".red)
        end

        it "raises an error if no crashlytics path was given" do
          expect do
            Fastlane::FastFile.new.parse("lane :test do
              crashlytics({
                api_token: 'wadus',
                build_secret: 'wadus',
                ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
              })
            end").runner.execute(:test)
          end.to raise_error("No Crashlytics path given or found, pass using `crashlytics_path: 'path'`".red)
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
          end.to raise_error("No Crashlytics path given or found, pass using `crashlytics_path: 'path'`".red)
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
          end.to raise_error("No API token for Crashlytics given, pass using `api_token: 'token'`".red)
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
          end.to raise_error("No build secret for Crashlytics given, pass using `build_secret: 'secret'`".red)
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
          end.to raise_error("Couldn't find ipa file at path ''".red)
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
          end.to raise_error("Couldn't find ipa file at path './fastlane/wadus'".red)
        end
      end
    end
  end
end
