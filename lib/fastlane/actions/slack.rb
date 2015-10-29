# rubocop:disable Style/CaseEquality
# rubocop:disable Style/MultilineTernaryOperator
# rubocop:disable Style/NestedTernaryOperator
module Fastlane
  module Actions
    class SlackAction < Action

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
        require 'slack-notifier'

        options[:message] = self.trim_message(options[:message].to_s || '')
        options[:message] = Slack::Notifier::LinkFormatter.format(options[:message])

        url = ENV['SLACK_URL']
        unless url
          Helper.log.fatal "Please add 'ENV[\"SLACK_URL\"] = \"https://hooks.slack.com/services/...\"' to your Fastfile's `before_all` section.".red
          raise 'No SLACK_URL given.'.red
        end

        notifier = Slack::Notifier.new(url)

        notifier.username = 'fastlane'
        if options[:channel].to_s.length > 0
          notifier.channel = options[:channel]
          notifier.channel = ('#' + notifier.channel) unless ['#', '@'].include?(notifier.channel[0]) # send message to channel by default
        end

        slack_attachment = generate_slack_attachments(options)

        return [notifier, slack_attachment] if Helper.is_test? # tests will verify the slack attachments and other properties

        result = notifier.ping '',
                               icon_url: 'https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png',
                               attachments: [slack_attachment]

        if result.code.to_i == 200
          Helper.log.info 'Successfully sent Slack notification'.green
        else
          Helper.log.debug result
          raise 'Error pushing Slack message, maybe the integration has no permission to post on this channel? Try removing the channel parameter in your Fastfile.'.red
        end
      end

      def self.description
        "Send a success/error message to your Slack group"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       env_name: "FL_SLACK_MESSAGE",
                                       description: "The message that should be displayed on Slack. This supports the standard Slack markup language",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :channel,
                                       env_name: "FL_SLACK_CHANNEL",
                                       description: "#channel or @username",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :slack_url,
                                       env_name: "SLACK_URL",
                                       description: "Create an Incoming WebHook for your Slack group",
                                       verify_block: proc do |value|
                                         raise "Invalid URL, must start with https://" unless value.start_with? "https://"
                                       end),
          FastlaneCore::ConfigItem.new(key: :payload,
                                       env_name: "FL_SLACK_PAYLOAD",
                                       description: "Add additional information to this post. payload must be a hash containg any key with any value",
                                       default_value: {},
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :default_payloads,
                                       env_name: "FL_SLACK_DEFAULT_PAYLOADS",
                                       description: "Remove some of the default payloads. More information about the available payloads on GitHub",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :attachment_properties,
                                       env_name: "FL_SLACK_ATTACHMENT_PROPERTIES",
                                       description: "Merge additional properties in the slack attachment, see https://api.slack.com/docs/attachments",
                                       default_value: {},
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :success,
                                       env_name: "FL_SLACK_SUCCESS",
                                       description: "Was this build successful? (true/false)",
                                       optional: true,
                                       default_value: true,
                                       is_string: false)
        ]
      end

      def self.author
        "KrauseFx"
      end

      #####################################################
      # @!group Helper
      #####################################################

      def self.generate_slack_attachments(options)
        color = (options[:success] ? 'good' : 'danger')
        should_add_payload = ->(payload_name) { options[:default_payloads].nil? || options[:default_payloads].include?(payload_name) }

        slack_attachment = {
          fallback: options[:message],
          text: options[:message],
          color: color,
          mrkdwn_in: ["pretext", "text", "fields", "message"],
          fields: []
        }

        # custom user payloads
        slack_attachment[:fields] += options[:payload].map do |k, v|
          {
            title: k.to_s,
            value: Slack::Notifier::LinkFormatter.format(v.to_s),
            short: false
          }
        end

        # lane
        if should_add_payload[:lane]
          slack_attachment[:fields] << {
            title: 'Lane',
            value: Actions.lane_context[Actions::SharedValues::LANE_NAME],
            short: true
          }
        end

        # test_result
        if should_add_payload[:test_result]
          slack_attachment[:fields] << {
            title: 'Result',
            value: (options[:success] ? 'Success' : 'Error'),
            short: true
          }
        end

        # git branch
        if Actions.git_branch && should_add_payload[:git_branch]
          slack_attachment[:fields] << {
            title: 'Git Branch',
            value: Actions.git_branch,
            short: true
          }
        end

        # git_author
        if Actions.git_author && should_add_payload[:git_author]
          if ENV['FASTLANE_SLACK_HIDE_AUTHOR_ON_SUCCESS'] && options[:success]
            # We only show the git author if the build failed
          else
            slack_attachment[:fields] << {
              title: 'Git Author',
              value: Actions.git_author,
              short: true
            }
          end
        end

        # last_git_commit
        if Actions.last_git_commit && should_add_payload[:last_git_commit]
          slack_attachment[:fields] << {
            title: 'Git Commit',
            value: Actions.last_git_commit,
            short: false
          }
        end

        # merge additional properties
        deep_merge(slack_attachment, options[:attachment_properties])
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
