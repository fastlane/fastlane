require 'fastlane/action'
require 'fastlane/actions/slack'

require_relative 'module'

module Scan
  class SlackPoster
    def run(results)
      return if Scan.config[:skip_slack]
      return if Scan.config[:slack_only_on_failure] && results[:failures] == 0
      return if Scan.config[:slack_url].to_s.empty?

      if Scan.config[:slack_channel].to_s.length > 0
        channel = Scan.config[:slack_channel]
        channel = ('#' + channel) unless ['#', '@'].include?(channel[0]) # send message to channel by default
      end

      username = Scan.config[:slack_use_webhook_configured_username_and_icon] ? nil : Scan.config[:slack_username]
      icon_url = Scan.config[:slack_use_webhook_configured_username_and_icon] ? nil : Scan.config[:slack_icon_url]
      fields = []

      if results[:build_errors]
        fields << {
          title: 'Build Errors',
          value: results[:build_errors].to_s,
          short: true
        }
      end

      if results[:failures]
        fields << {
          title: 'Test Failures',
          value: results[:failures].to_s,
          short: true
        }
      end

      if results[:tests] && results[:failures]
        fields << {
          title: 'Successful Tests',
          value: (results[:tests] - results[:failures]).to_s,
          short: true
        }
      end

      Fastlane::Actions::SlackAction.run({
        message: "#{Scan.project.app_name} Tests:\n#{Scan.config[:slack_message]}",
        channel: channel,
        slack_url: Scan.config[:slack_url].to_s,
        success: results[:build_errors].to_i == 0 && results[:failures].to_i == 0,
        username: username,
        icon_url: icon_url,
        payload: {},
        attachment_properties: {
          fields: fields
        }
      })
    end
  end
end
