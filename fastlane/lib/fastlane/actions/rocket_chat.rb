# rubocop:disable Style/CaseEquality
# rubocop:disable Style/MultilineTernaryOperator
# rubocop:disable Style/NestedTernaryOperator
module Fastlane
  module Actions
    class RocketchatAction < Action
      def self.is_supported?(platform)
        true
      end

      # As there is a text limit in the notifications, we are
      # usually interested in the last part of the message
      # e.g. for tests
      def self.trim_message(message)
        # We want the last 7000 characters, instead of the first 7000, as the error is at the bottom
        start_index = [message.length - 7000, 0].max
        message = message[start_index..-1]
        message
      end

      def self.run(options)
        require 'rocket-chat-notifier'

        options[:message] = self.trim_message(options[:message].to_s || '')

        notifier = RocketChat::Notifier.new(options[:rocket_chat_url])

        notifier.username = options[:use_webhook_configured_username_and_icon] ? nil : options[:username]
        icon_url = options[:use_webhook_configured_username_and_icon] ? nil : options[:icon_url]

        if options[:channel].to_s.length > 0
          notifier.channel = options[:channel]
          notifier.channel = ('#' + notifier.channel) unless ['#', '@'].include?(notifier.channel[0]) # send message to channel by default
        end

        attachment = generate_attachments(options)

        return [notifier, attachment] if Helper.is_test? # tests will verify the rocket chat attachments and other properties

        result = notifier.ping '',
                               icon_url: icon_url,
                               attachments: [attachment]

        if result.code.to_i == 200
          UI.success('Successfully sent RocketChat notification')
        else
          UI.verbose(result)
          UI.user_error!("Error pushing RocketChat message, maybe the integration has no permission to post on this channel? Try removing the channel parameter in your Fastfile.")
        end
      end

      def self.description
        "Send a success/error message to your RocketChat group"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_ROCKET_CHAT_MESSAGE",
                                       description: "The message that should be displayed on Rocket.Chat. This supports the standard Rocket.Chat markup language",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :channel,
                                       env_name: "FL_ROCKET_CHAT_CHANNEL",
                                       description: "#channel or @username",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :use_webhook_configured_username_and_icon,
                                       env_name: "FL_ROCKET_CHAT_USE_WEBHOOK_CONFIGURED_USERNAME_AND_ICON",
                                       description: "Use webook's default username and icon settings? (true/false)",
                                       default_value: false,
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :rocket_chat_url,
                                       env_name: "ROCKET_CHAT_URL",
                                       description: "Create an Incoming WebHook for your Rocket.Chat group",
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid URL, must start with https://") unless value.start_with? "https://"
                                       end),
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_ROCKET_CHAT_USERNAME",
                                       description: "Overrides the webook's username property if use_webhook_configured_username_and_icon is false",
                                       default_value: "fastlane",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :icon_url,
                                       env_name: "FL_ROCKET_CHAT_ICON_URL",
                                       description: "Overrides the webook's image property if use_webhook_configured_username_and_icon is false",
                                       default_value: "https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png",
                                       is_string: true,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :payload,
                                       env_name: "FL_ROCKET_CHAT_PAYLOAD",
                                       description: "Add additional information to this post. payload must be a hash containg any key with any value",
                                       default_value: {},
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :default_payloads,
                                       env_name: "FL_ROCKET_CHAT_DEFAULT_PAYLOADS",
                                       description: "Remove some of the default payloads. More information about the available payloads on GitHub",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :attachment_properties,
                                       env_name: "FL_ROCKET_CHAT_ATTACHMENT_PROPERTIES",
                                       description: "Merge additional properties in the Rocket.Chat attachment",
                                       default_value: {},
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :success,
                                       env_name: "FL_ROCKET_CHAT_SUCCESS",
                                       description: "Was this build successful? (true/false)",
                                       optional: true,
                                       default_value: true,
                                       is_string: false)
        ]
      end

      def self.author
        "thiagofelix"
      end

      #####################################################
      # @!group Helper
      #####################################################

      def self.generate_attachments(options)
        color = (options[:success] ? 'good' : 'danger')
        should_add_payload = ->(payload_name) { options[:default_payloads].nil? || options[:default_payloads].include?(payload_name) }

        attachment = {
          fallback: options[:message],
          text: options[:message],
          color: color,
          mrkdwn_in: ["pretext", "text", "fields", "message"],
          fields: []
        }

        # custom user payloads
        attachment[:fields] += options[:payload].map do |k, v|
          {
            title: k.to_s,
            value: v.to_s
          }
        end

        # Add the lane to the Rocket.Chat message
        # This might be nil, if Rocket.Chat is called as "one-off" action
        if should_add_payload[:lane] && Actions.lane_context[Actions::SharedValues::LANE_NAME]
          attachment[:fields] << {
            title: 'Lane',
            value: Actions.lane_context[Actions::SharedValues::LANE_NAME]
          }
        end

        # test_result
        if should_add_payload[:test_result]
          attachment[:fields] << {
            title: 'Result',
            value: (options[:success] ? 'Success' : 'Error')
          }
        end

        # git branch
        if Actions.git_branch && should_add_payload[:git_branch]
          attachment[:fields] << {
            title: 'Git Branch',
            value: Actions.git_branch
          }
        end

        # git_author
        if Actions.git_author_email && should_add_payload[:git_author]
          unless ENV['FASTLANE_ROCKET_CHAT_HIDE_AUTHOR_ON_SUCCESS'] && options[:success]
            attachment[:fields] << {
              title: 'Git Author',
              value: Actions.git_author_email
            }
          end
        end

        # last_git_commit
        if Actions.last_git_commit_message && should_add_payload[:last_git_commit]
          attachment[:fields] << {
            title: 'Git Commit',
            value: Actions.last_git_commit_message
          }
        end

        # merge additional properties
        deep_merge(attachment, options[:attachment_properties])
      end

      # Adapted from http://stackoverflow.com/a/30225093/158525
      def self.deep_merge(a, b)
        merger = proc do |key, v1, v2|
          Hash === v1 && Hash === v2 ?
                 v1.merge(v2, &merger) : Array === v1 && Array === v2 ?
                   v1 | v2 : [:undefined, nil, :nil].include?(v2) ? v1 : v2
        end
        a.merge(b, &merger)
      end
    end
  end
end
# rubocop:enable Style/CaseEquality
# rubocop:enable Style/MultilineTernaryOperator
# rubocop:enable Style/NestedTernaryOperator
