require 'scan'
require 'slack-notifier'

describe Scan::SlackPoster do
  describe "slack_url handling" do
    describe "without a slack_url set" do
      it "skips Slack posting", requires_xcodebuild: true do
        # ensures that people's local environment variable doesn't interfere with this test
        with_env_values('SLACK_URL' => nil) do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj'
          })

          expect(Slack::Notifier).not_to(receive(:new))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the slack_url option set but skip_slack set to true" do
      it "skips Slack posting", requires_xcodebuild: true do
        # ensures that people's local environment variable doesn't interfere with this test
        with_env_values('SLACK_URL' => nil) do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj',
            slack_url: 'https://slack/hook/url',
            skip_slack: true
          })

          expect(Slack::Notifier).not_to(receive(:new))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the SLACK_URL ENV var set but skip_slack set to true" do
      it "skips Slack posting", requires_xcodebuild: true do
        with_env_values('SLACK_URL' => 'https://slack/hook/url') do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj',
            skip_slack: true
          })

          expect(Slack::Notifier).not_to(receive(:new))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the SLACK_URL ENV var set to empty string" do
      it "skips Slack posting", requires_xcodebuild: true do
        with_env_values('SLACK_URL' => '') do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj'
          })

          expect(Slack::Notifier).not_to(receive(:new))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    describe "with the slack_url option set to empty string" do
      it "skips Slack posting", requires_xcodebuild: true do
        # ensures that people's local environment variable doesn't interfere with this test
        with_env_values('SLACK_URL' => nil) do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj',
            slack_url: ''
          })

          expect(Slack::Notifier).not_to(receive(:new))

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end

    def expect_slack_posting
      fake_notifier = "fake_notifier"
      fake_result = "fake_result"
      expect(Slack::Notifier).to receive(:new).and_return(fake_notifier)
      expect(fake_notifier).to receive(:ping).and_return([fake_result])
      expect(fake_result).to receive(:code).and_return(200)
    end

    describe "with slack_url option set to a URL value" do
      it "does Slack posting", requires_xcodebuild: true do
        expect_slack_posting

        # ensures that people's local environment variable doesn't interfere with this test
        with_env_values('SLACK_URL' => nil) do
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
        expect_slack_posting

        with_env_values('SLACK_URL' => 'https://slack/hook/url') do
          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, {
            project: './scan/examples/standard/app.xcodeproj'
          })

          Scan::SlackPoster.new.run({ tests: 0, failures: 0 })
        end
      end
    end
  end
end
