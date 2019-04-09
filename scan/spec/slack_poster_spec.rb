require 'scan'
require 'slack-notifier'

describe Scan::SlackPoster do
  describe "slack_url handling" do
    describe "without a slack_url set" do
      it "skips Slack posting", requires_xcodebuild: true do
        # ensures that people's local environment variable doesn't interfere with this test
        FastlaneSpec::Env.with_env_values('SLACK_URL' => nil) do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj'
          })

          expect(Fastlane::Actions::SlackAction).not_to(receive(:run))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the slack_url option set but skip_slack set to true" do
      it "skips Slack posting", requires_xcodebuild: true do
        # ensures that people's local environment variable doesn't interfere with this test
        FastlaneSpec::Env.with_env_values('SLACK_URL' => nil) do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj',
            slack_url: 'https://slack/hook/url',
            skip_slack: true
          })

          expect(Fastlane::Actions::SlackAction).not_to(receive(:run))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the SLACK_URL ENV var set but skip_slack set to true" do
      it "skips Slack posting", requires_xcodebuild: true do
        FastlaneSpec::Env.with_env_values('SLACK_URL' => 'https://slack/hook/url') do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj',
            skip_slack: true
          })

          expect(Fastlane::Actions::SlackAction).not_to(receive(:run))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the SLACK_URL ENV var set to empty string" do
      it "skips Slack posting", requires_xcodebuild: true do
        FastlaneSpec::Env.with_env_values('SLACK_URL' => '') do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj'
          })

          expect(Fastlane::Actions::SlackAction).not_to(receive(:run))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the slack_url option set to empty string" do
      it "skips Slack posting", requires_xcodebuild: true do
        # ensures that people's local environment variable doesn't interfere with this test
        FastlaneSpec::Env.with_env_values('SLACK_URL' => nil) do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj',
            slack_url: ''
          })

          expect(Fastlane::Actions::SlackAction).not_to(receive(:run))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    def expect_slack_posting
      expect(Fastlane::Actions::SlackAction).to receive(:run).with(
        hash_including({
          message: a_string_matching(' Tests:'),
          channel: nil,
          slack_url: 'https://slack/hook/url',
          username: 'fastlane',
          icon_url: 'https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png',
          attachment_properties: {
            fields: [
              {
                title: 'Test Failures',
                value: '0',
                short: true
              },
              {
                title: 'Successful Tests',
                value: '0',
                short: true
              }
            ]
          }
        })
      )
    end

    describe "with slack_url option set to a URL value" do
      it "does Slack posting", requires_xcodebuild: true do
        # ensures that people's local environment variable doesn't interfere with this test
        FastlaneSpec::Env.with_env_values('SLACK_URL' => nil) do
          expect(ENV['SLACK_URL']).to eq(nil)
          expect_slack_posting

          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj',
            slack_url: 'https://slack/hook/url'
          })

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with SLACK_URL ENV var set to a URL value" do
      it "does Slack posting", requires_xcodebuild: true do
        FastlaneSpec::Env.with_env_values('SLACK_URL' => 'https://slack/hook/url') do
          expect(ENV['SLACK_URL']).to eq('https://slack/hook/url')
          expect_slack_posting

          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj'
          })

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end
  end
end
