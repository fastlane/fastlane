module Fastlane
  module Notification
    class Slack
      def initialize(webhook_url)
        @webhook_url = webhook_url
        @client = Faraday.new do |conn|
          conn.use(Faraday::Response::RaiseError)
        end
      end

      # Overriding channel, icon_url, icon_emoji and username is only supported in legacy incoming webhook.
      # Also note that the use of attachments has been discouraged by Slack, in favor of Block Kit.
      # https://api.slack.com/legacy/custom-integrations/messaging/webhooks
      def post_to_legacy_incoming_webhook(channel:, username:, attachments:, link_names:, icon_url:, icon_emoji:)
        @client.post(@webhook_url) do |request|
          request.headers['Content-Type'] = 'application/json'
          request.body = {
            channel: channel,
            username: username,
            icon_url: icon_url,
            icon_emoji: icon_emoji,
            attachments: attachments,
            link_names: link_names
          }.to_json
        end
      end

      # This class was inspired by `LinkFormatter` in `slack-notifier` gem
      # https://github.com/stevenosloan/slack-notifier/blob/4bf6582663dc9e5070afe3fdc42d67c14a513354/lib/slack-notifier/util/link_formatter.rb
      class LinkConverter
        HTML_PATTERN = %r{<a.*?href=['"](?<link>#{URI.regexp})['"].*?>(?<label>.+?)<\/a>}
        MARKDOWN_PATTERN = /\[(?<label>[^\[\]]*?)\]\((?<link>#{URI.regexp}|mailto:#{URI::MailTo::EMAIL_REGEXP})\)/

        def self.convert(string)
          convert_markdown_to_slack_link(convert_html_to_slack_link(string.scrub))
        end

        def self.convert_html_to_slack_link(string)
          string.gsub(HTML_PATTERN) do |match|
            slack_link(Regexp.last_match[:link], Regexp.last_match[:label])
          end
        end

        def self.convert_markdown_to_slack_link(string)
          string.gsub(MARKDOWN_PATTERN) do |match|
            slack_link(Regexp.last_match[:link], Regexp.last_match[:label])
          end
        end

        def self.slack_link(href, text)
          return "<#{href}>" if text.nil? || text.empty?
          "<#{href}|#{text}>"
        end
      end
    end
  end
end
