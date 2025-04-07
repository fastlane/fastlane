require 'slack-notifier'

describe Fastlane::Actions do
  describe Fastlane::Actions::SlackAction do
    describe Fastlane::Actions::SlackAction::Runner do
      subject { Fastlane::Actions::SlackAction::Runner.new('https://127.0.0.1') }

      it "trims long messages to show the bottom of the messages" do
        long_text = "a" * 10_000
        expect(described_class.trim_message(long_text).length).to eq(7000)
      end

      it "works so perfect, like Slack does" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          icon_emoji: ':white_check_mark:',
          payload: {
            'Build Date' => Time.new.to_s,
            'Built by' => 'Jenkins'
          },
          default_payloads: [:lane, :test_result, :git_branch, :git_author, :last_git_commit_hash]
        })

        expected_args = {
          channel: channel,
          username: 'fastlane',
          attachments: [
            hash_including(
              color: 'danger',
              pretext: nil,
              text: message,
              fields: array_including(
                { title: 'Built by', value: 'Jenkins', short: false },
                { title: 'Lane', value: lane_name, short: true },
                { title: 'Result', value: 'Error', short: true }
              )
            )
          ],
          link_names: false,
          icon_url: 'https://fastlane.tools/assets/img/fastlane_icon.png',
          icon_emoji: ':white_check_mark:',
          fail_on_error: true
        }
        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end

      it "works so perfect, like Slack does with pretext" do
        channel = "#myChannel"
        message = "Custom Message"
        pretext = "This is pretext"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          message: message,
          pretext: pretext,
          success: false,
          channel: channel
        })

        expected_args = hash_including(
          attachments: [
            hash_including(
              color: 'danger',
              pretext: pretext,
              text: message
            )
          ]
        )

        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end

      it "merges attachment_properties when specified" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/slack'
        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          default_payloads: [:lane],
          attachment_properties: {
            thumb_url: 'https://example.com/path/to/thumb.png',
            fields: [{
              title: 'My Field',
              value: 'My Value',
              short: true
            }]
          }
        })

        expected_args = hash_including(
          attachments: [
            hash_including(
              fields: array_including(
                { title: 'Lane', value: lane_name, short: true },
                { title: 'My Field', value: 'My Value', short: true }
              )
            )
          ]
        )
        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end

      it "parses default_payloads from a comma delimited string" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          default_payloads: "lane,test_result"
        })

        expected_args = hash_including(
          attachments: [
            hash_including(
              fields: [
                { title: 'Lane', value: lane_name, short: true },
                { title: 'Result', value: 'Error', short: true }
              ]
            )
          ]
        )
        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end

      # https://github.com/fastlane/fastlane/issues/14234
      it "parses default_payloads without adding extra fields for git" do
        channel = "#myChannel"
        message = "Custom Message"

        require 'fastlane/actions/slack'
        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          default_payloads: [:git_branch, :last_git_commit_hash]
        })

        expected_args = hash_including(
          attachments: [
            hash_including(
              fields: [
                { title: 'Git Branch', value: anything, short: true },
                { title: 'Git Commit Hash', value: anything, short: false }
              ]
            )
          ]
        )
        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end

      it "receives default_payloads as nil and falls back to its default value" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/slack'

        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          default_payloads: nil
        })

        expected_args = hash_including(
          attachments: [
            hash_including(
              fields: [
                { title: 'Lane', value: lane_name, short: true },
                { title: 'Result', value: anything, short: true },
                { title: 'Git Branch', value: anything, short: true },
                { title: 'Git Author', value: anything, short: true },
                { title: 'Git Commit', value: anything, short: false },
                { title: 'Git Commit Hash', value: anything, short: false }
              ]
            )
          ]
        )
        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end

      # https://github.com/fastlane/fastlane/issues/14141
      it "prints line breaks on message parameter to slack" do
        channel = "#myChannel"
        # User is passing input_message through fastlane input parameter
        input_message = 'Custom Message with\na line break'
        # We expect the message to be escaped correctly after being processed by action
        expected_message = "Custom Message with\na line break"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          message: input_message,
          success: false,
          channel: channel
        })

        expected_args = hash_including(
          attachments: [
            hash_including(
              color: 'danger',
              text: expected_message
            )
          ]
        )
        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end

      # https://github.com/fastlane/fastlane/issues/14141
      it "prints line breaks on pretext parameter to slack" do
        channel = "#myChannel"
        # User is passing input_message through fastlane input parameter
        input_pretext = 'Custom Pretext with\na line break'
        # We expect the message to be escaped correctly after being processed by action
        expected_pretext = "Custom Pretext with\na line break"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        options = FastlaneCore::Configuration.create(Fastlane::Actions::SlackAction.available_options, {
          slack_url: 'https://127.0.0.1',
          pretext: input_pretext,
          success: false,
          channel: channel
        })

        expected_args = hash_including(
          attachments: [
            hash_including(
              color: 'danger',
              pretext: expected_pretext
            )
          ]
        )
        expect(subject).to receive(:post_message).with(expected_args)
        subject.run(options)
      end
    end
  end
end
