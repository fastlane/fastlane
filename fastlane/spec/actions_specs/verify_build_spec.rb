describe Fastlane do
  describe Fastlane::FastFile do
    describe "verify_build" do
      let(:no_such_file) { "no-such-file.ipa" }
      let(:not_an_ipa) { File.expand_path("./fastlane_core/spec/fixtures/ipas/not-an-ipa.ipa") }
      let(:correctly_signed_ipa) { File.expand_path("./fastlane_core/spec/fixtures/ipas/very-capable-app.ipa") }
      let(:incorrectly_signed_ipa) { File.expand_path("./fastlane_core/spec/fixtures/ipas/ContainsWatchApp.ipa") }

      before(:each) do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = nil
        allow(FastlaneCore::UI).to receive(:success).with("Driving the lane 'test' 🚀")
      end

      if FastlaneCore::Helper.mac?
        it "uses the ipa output path from lane context" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = correctly_signed_ipa

          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
                verify_build
            end").runner.execute(:test)
        end

        it "uses ipa set via ipa_path" do
          expect(FastlaneCore::UI).to receive(:success).with("Build is verified, have a 🍪.")
          Fastlane::FastFile.new.parse("lane :test do
                verify_build(
                    ipa_path: '#{correctly_signed_ipa}'
                )
            end").runner.execute(:test)
        end
      end

      describe "Missing ipa file" do
        it "raises an error if ipa file path set via lane context does not exist" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = no_such_file

          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find ipa file '#{no_such_file}'.").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
                verify_build
            end").runner.execute(:test)
          end.to raise_error("Unable to find ipa file '#{no_such_file}'.")
        end

        it "raises an error if specified ipa file does not exist" do
          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find ipa file '#{no_such_file}'.").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
                verify_build(
                    ipa_path: '#{no_such_file}'
                )
            end").runner.execute(:test)
          end.to raise_error("Unable to find ipa file '#{no_such_file}'.")
        end

        it "ignores ipa path from lane context if custom ipa is specified" do
          Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = correctly_signed_ipa

          expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to find ipa file '#{no_such_file}'.").and_call_original
          expect do
            Fastlane::FastFile.new.parse("lane :test do
                verify_build(
                    ipa_path: '#{no_such_file}'
                )
            end").runner.execute(:test)
          end.to raise_error("Unable to find ipa file '#{no_such_file}'.")
        end
      end

      it "raises an error if ipa is not signed correctly" do
        expect(FastlaneCore::UI).to receive(:user_error!).with("Unable to verify code signing").and_call_original
        expect do
          Fastlane::FastFile.new.parse("lane :test do
              verify_build(
                  ipa_path: '#{incorrectly_signed_ipa}'
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
    end
  end
end
