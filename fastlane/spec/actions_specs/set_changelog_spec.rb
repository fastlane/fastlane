describe Fastlane do
  describe Fastlane::FastFile do
    describe "set_changelog" do
      context 'with invalid platform' do
        let(:invalidPlatform_lane) { "lane :test do set_changelog(app_identifier: 'x.y.z', platform: 'whatever', changelog: 'custom changelog', username: 'name@example.com') end" }

        it 'raises a Fastlane error' do
          expect { Fastlane::FastFile.new.parse(invalidPlatform_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Invalid platform 'whatever', must be ios, appletvos, xros, mac/)
            end
          )
        end
      end

      context 'with invalid app_identifier' do
        let(:validPlatform_lane) { "lane :test do set_changelog(app_identifier: 'x.y.z', platform: 'ios', changelog: 'custom changelog', username: 'name@example.com') end" }

        it 'raises a Fastlane error' do
          allow(Spaceship::ConnectAPI).to receive(:login).and_return(true)
          allow(Spaceship::ConnectAPI).to receive(:select_team).and_return(true)
          allow(Spaceship::ConnectAPI::App).to receive(:find).and_return(nil)

          expect { Fastlane::FastFile.new.parse(validPlatform_lane).runner.execute(:test) }.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match(/Couldn't find app with identifier x.y.z/)
            end
          )
        end
      end

      context "when it cannot ask for input" do
        let(:app) { double("app", get_edit_app_store_version: nil) }

        before do
          allow(Spaceship::ConnectAPI).to receive(:login).and_return(true)
          allow(Spaceship::ConnectAPI::App).to receive(:find).and_return(app)
          allow(FastlaneCore::Helper).to receive(:can_prompt?).and_return(false)
          expect(STDIN).not_to(receive(:gets))
        end

        it "asks for the version option instead of reading one" do
          lane = "lane :test do set_changelog(app_identifier: 'x.y.z', changelog: 'custom changelog', username: 'name@example.com') end"
          expect { Fastlane::FastFile.new.parse(lane).runner.execute(:test) }.to raise_error(FastlaneCore::Interface::FastlaneError, "No version is being edited: pass the new one with the `version` option")
        end

        it "asks for the changelog option instead of reading one" do
          allow(Fastlane::Actions::SetChangelogAction).to receive(:default_changelog_path).and_return("./missing/changelog.txt")
          lane = "lane :test do set_changelog(app_identifier: 'x.y.z', version: '1.0', username: 'name@example.com') end"
          expect { Fastlane::FastFile.new.parse(lane).runner.execute(:test) }.to raise_error(FastlaneCore::Interface::FastlaneError, "Pass the changelog with the `changelog` option, or write it to ./missing/changelog.txt")
        end
      end
    end
  end
end
