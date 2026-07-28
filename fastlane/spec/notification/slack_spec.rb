require 'json'

describe Fastlane::Notification::Slack do
  describe '#post_to_legacy_incoming_webhook' do
    let(:webhook_url) { 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX' }
    let(:slack) { described_class.new(webhook_url) }

    describe 'thread_ts parameter' do
      it 'includes thread_ts in request body when thread_ts is provided' do
        thread_ts = '1234567890.123456'
        captured_body = nil

        stub_request(:post, webhook_url)
          .with { |request|
            body = request.body
            captured_body = body.kind_of?(String) ? JSON.parse(body) : body
            true
          }
          .to_return(status: 200, body: 'ok')

        slack.post_to_legacy_incoming_webhook(
          channel: '#channel',
          username: 'fastlane',
          attachments: [],
          link_names: false,
          icon_url: nil,
          icon_emoji: nil,
          thread_ts: thread_ts
        )

        body_hash = captured_body.kind_of?(Hash) ? captured_body : JSON.parse(captured_body)
        expect(body_hash['thread_ts'] || body_hash[:thread_ts]).to eq(thread_ts)
      end

      it 'does not include thread_ts in request body when thread_ts is nil' do
        captured_body = nil

        stub_request(:post, webhook_url)
          .with { |request|
            body = request.body
            captured_body = body.kind_of?(String) ? JSON.parse(body) : body
            true
          }
          .to_return(status: 200, body: 'ok')

        slack.post_to_legacy_incoming_webhook(
          channel: '#channel',
          username: 'fastlane',
          attachments: [],
          link_names: false,
          icon_url: nil,
          icon_emoji: nil,
          thread_ts: nil
        )

        body_hash = captured_body.kind_of?(Hash) ? captured_body : JSON.parse(captured_body)
        expect(body_hash).not_to have_key('thread_ts')
        expect(body_hash).not_to have_key(:thread_ts)
      end

      it 'does not include thread_ts in request body when thread_ts is empty string' do
        captured_body = nil

        stub_request(:post, webhook_url)
          .with { |request|
            body = request.body
            captured_body = body.kind_of?(String) ? JSON.parse(body) : body
            true
          }
          .to_return(status: 200, body: 'ok')

        slack.post_to_legacy_incoming_webhook(
          channel: '#channel',
          username: 'fastlane',
          attachments: [],
          link_names: false,
          icon_url: nil,
          icon_emoji: nil,
          thread_ts: ''
        )

        body_hash = captured_body.kind_of?(Hash) ? captured_body : JSON.parse(captured_body)
        expect(body_hash).not_to have_key('thread_ts')
        expect(body_hash).not_to have_key(:thread_ts)
      end
    end
  end

  describe Fastlane::Notification::Slack::LinkConverter do
    it 'should convert HTML anchor tag to Slack link format' do
      {
        %|Hello <a href="https://fastlane.tools">fastlane</a>| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello <a href='https://fastlane.tools'>fastlane</a>| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello <a id="foo" href="https://fastlane.tools">fastlane</a>| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello <a href="https://fastlane.tools">fastlane</a> <a href="https://github.com/fastlane">GitHub</a>| => 'Hello <https://fastlane.tools|fastlane> <https://github.com/fastlane|GitHub>'
      }.each do |input, output|
        expect(described_class.convert(input)).to eq(output)
      end
    end

    it 'should convert Markdown link to Slack link format' do
      {
        %|Hello [fastlane](https://fastlane.tools)| => 'Hello <https://fastlane.tools|fastlane>',
        %|Hello [fastlane](mailto:fastlane@fastlane.tools)| => 'Hello <mailto:fastlane@fastlane.tools|fastlane>',
        %|Hello [fastlane](https://fastlane.tools) [GitHub](https://github.com/fastlane)| => 'Hello <https://fastlane.tools|fastlane> <https://github.com/fastlane|GitHub>',
        %|Hello [[fastlane](https://fastlane.tools) in brackets]| => 'Hello [<https://fastlane.tools|fastlane> in brackets]',
        %|Hello [](https://fastlane.tools)| => 'Hello <https://fastlane.tools>',
        %|Hello ([fastlane](https://fastlane.tools) in parens)| => 'Hello (<https://fastlane.tools|fastlane> in parens)',
        %|Hello ([fastlane(:rocket:)](https://fastlane.tools) in parens)| => 'Hello (<https://fastlane.tools|fastlane(:rocket:)> in parens)'
      }.each do |input, output|
        expect(described_class.convert(input)).to eq(output)
      end
    end
  end
end
