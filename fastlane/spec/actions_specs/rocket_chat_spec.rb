describe Fastlane do
  describe Fastlane::FastFile do
    describe "RocketChat Action", now: true do
      before :each do
        ENV['ROCKET_CHAT_URL'] = 'https://127.0.0.1'
      end

      it "trims long messages to show the bottom of the messages" do
        long_text = "a" * 10_000
        expect(Fastlane::Actions::RocketchatAction.trim_message(long_text).length).to eq(7000)
      end

      it "works so perfect, like RocketChat does" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/rocket_chat'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::RocketchatAction, {
          rocket_chat_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          payload: {
            'Build Date' => Time.new.to_s,
            'Built by' => 'Jenkins'
          },
          default_payloads: [:lane, :test_result, :git_branch, :git_author]
        })

        notifier, attachments = Fastlane::Actions::RocketchatAction.run(arguments)

        expect(notifier.default_payload[:username]).to eq('fastlane')
        expect(notifier.default_payload[:channel]).to eq(channel)

        expect(attachments[:color]).to eq('danger')
        expect(attachments[:text]).to eq(message)

        fields = attachments[:fields]
        expect(fields[1][:title]).to eq('Built by')
        expect(fields[1][:value]).to eq('Jenkins')

        expect(fields[2][:title]).to eq('Lane')
        expect(fields[2][:value]).to eq(lane_name)

        expect(fields[3][:title]).to eq('Result')
        expect(fields[3][:value]).to eq('Error')
      end

      it "merges attachment_properties when specified" do
        channel = "#myChannel"
        message = "Custom Message"
        lane_name = "lane_name"

        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = lane_name

        require 'fastlane/actions/rocket_chat'
        arguments = Fastlane::ConfigurationHelper.parse(Fastlane::Actions::RocketchatAction, {
          rocket_chat_url: 'https://127.0.0.1',
          message: message,
          success: false,
          channel: channel,
          default_payloads: [:lane],
          attachment_properties: {
            thumb_url: 'https://example.com/path/to/thumb.png',
            fields: [{
              title: 'My Field',
              value: 'My Value'
            }]
          }
        })

        notifier, attachments = Fastlane::Actions::RocketchatAction.run(arguments)

        fields = attachments[:fields]

        expect(fields[0][:title]).to eq('Lane')
        expect(fields[0][:value]).to eq(lane_name)

        expect(fields[1][:title]).to eq('My Field')
        expect(fields[1][:value]).to eq('My Value')

        expect(attachments[:thumb_url]).to eq('https://example.com/path/to/thumb.png')
      end
    end
  end
end
