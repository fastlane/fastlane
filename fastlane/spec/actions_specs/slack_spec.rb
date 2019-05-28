describe Fastlane do
  describe Fastlane::FastFile do
    describe "Slack Action" do
      before :each do
        ENV['SLACK_URL'] = 'https://127.0.0.1'
      end

      it "trims long messages to show the bottom of the messages" do
        long_text = "a" * 10_000
        expect(Fastlane::Actions::SlackAction.trim_message(long_text).length).to eq(7000)
      end

      it "works so perfect, like Slack does" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/slack'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::SlackAction, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          payload: {
            'Build Date' => Time.new.to_s,
            'Built by' => 'Jenkins'
          },
          default_payloads: [:lane, :test_result, :git_branch, :git_author, :last_git_commit_hash]
        })

        notifier, attachments = Fastlane::Actions::SlackAction.run(arguments)

        expect(notifier.config.defaults[:username]).to eq('fastlane')
        expect(notifier.config.defaults[:channel]).to eq(channel)

        expect(attachments[:color]).to eq('danger')
        expect(attachments[:text]).to eq(message)
        expect(attachments[:pretext]).to eq(nil)

        fields = attachments[:fields]
        expect(fields[1][:title]).to eq('Built by')
        expect(fields[1][:value]).to eq('Jenkins')

        expect(fields[2][:title]).to eq('Lane')
        expect(fields[2][:value]).to eq(lane_name)

        expect(fields[3][:title]).to eq('Result')
        expect(fields[3][:value]).to eq('Error')
      end

      it "works so perfect, like Slack does with pretext" do
        channel = "#myChannel"
        message = "Custom Message"
        pretext = "This is pretext"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/slack'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::SlackAction, {
          slack_url: 'https://127.0.0.1',
          message: message,
          pretext: pretext,
          success: false,
          channel: channel
        })

        notifier, attachments = Fastlane::Actions::SlackAction.run(arguments)

        expect(notifier.config.defaults[:username]).to eq('fastlane')
        expect(notifier.config.defaults[:channel]).to eq(channel)

        expect(attachments[:color]).to eq('danger')
        expect(attachments[:text]).to eq(message)
        expect(attachments[:pretext]).to eq(pretext)
      end

      it "merges attachment_properties when specified" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/slack'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::SlackAction, {
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

        notifier, attachments = Fastlane::Actions::SlackAction.run(arguments)

        fields = attachments[:fields]

        expect(fields[0][:title]).to eq('Lane')
        expect(fields[0][:value]).to eq(lane_name)

        expect(fields[1][:title]).to eq('My Field')
        expect(fields[1][:value]).to eq('My Value')
        expect(fields[1][:short]).to eq(true)

        expect(attachments[:thumb_url]).to eq('https://example.com/path/to/thumb.png')
      end

      it "parses default_payloads from a comma delimited string" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/slack'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::SlackAction, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          default_payloads: "lane,test_result"
        })

        notifier, attachments = Fastlane::Actions::SlackAction.run(arguments)

        fields = attachments[:fields]

        expect(fields[0][:title]).to eq('Lane')
        expect(fields[0][:value]).to eq(lane_name)

        expect(fields[1][:title]).to eq('Result')
        expect(fields[1][:value]).to eq('Error')
      end

      # https://github.com/fastlane/fastlane/issues/14234
      it "parses default_payloads without adding extra fields for git" do
        channel = "#myChannel"
        message = "Custom Message"

        require 'fastlane/actions/slack'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::SlackAction, {
          slack_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          default_payloads: [:git_branch, :last_git_commit_hash]
        })

        notifier, attachments = Fastlane::Actions::SlackAction.run(arguments)

        fields = attachments[:fields]

        expect(fields.count).to eq(2)

        expect(fields[0][:title]).to eq('Git Branch')
        expect(fields[1][:title]).to eq('Git Commit Hash')
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

        require 'fastlane/actions/slack'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::SlackAction, {
          slack_url: 'https://127.0.0.1',
          message: input_message,
          success: false,
          channel: channel
        })

        notifier, attachments = Fastlane::Actions::SlackAction.run(arguments)

        expect(notifier.config.defaults[:username]).to eq('fastlane')
        expect(notifier.config.defaults[:channel]).to eq(channel)

        expect(attachments[:color]).to eq('danger')
        expect(attachments[:text]).to eq(expected_message)
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

        require 'fastlane/actions/slack'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::SlackAction, {
          slack_url: 'https://127.0.0.1',
          pretext: input_pretext,
          success: false,
          channel: channel
        })

        notifier, attachments = Fastlane::Actions::SlackAction.run(arguments)

        expect(notifier.config.defaults[:username]).to eq('fastlane')
        expect(notifier.config.defaults[:channel]).to eq(channel)

        expect(attachments[:color]).to eq('danger')
        expect(attachments[:pretext]).to eq(expected_pretext)
      end
    end
  end
end
