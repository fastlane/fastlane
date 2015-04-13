module Fastlane
  module Actions
    class SlackAction < Action
      def self.git_author
        s = `git log --name-status HEAD^..HEAD`
        s = s.match(/Author:.*<(.*)>/)[1]
        return s if s.to_s.length > 0
        return nil
      rescue
        return nil
      end

      def self.last_git_commit
        s = `git log -1 --pretty=%B`.strip
        return s if s.to_s.length > 0
        nil
      end

      def self.run(params)
        options = { message: '',
                    success: true,
                    channel: nil,
                    payload: {}
                  }.merge(params.first || {})

        require 'slack-notifier'

        color = (options[:success] ? 'good' : 'danger')
        options[:message] = options[:message].to_s

        options[:message] = Slack::Notifier::LinkFormatter.format(options[:message])

        url = ENV['SLACK_URL']
        unless url
          Helper.log.fatal "Please add 'ENV[\"SLACK_URL\"] = \"https://hooks.slack.com/services/...\"' to your Fastfile's `before_all` section.".red
          raise 'No SLACK_URL given.'.red
        end

        notifier = Slack::Notifier.new url

        notifier.username = 'fastlane'
        if options[:channel].to_s.length > 0
          notifier.channel = options[:channel]
          notifier.channel = ('#' + notifier.channel) unless ['#', '@'].include?(notifier.channel[0]) # send message to channel by default
        end

        should_add_payload = ->(payload_name) { options[:default_payloads].nil? || options[:default_payloads].include?(payload_name) }

        slack_attachment = {
          fallback: options[:message],
          text: options[:message],
          color: color,
          fields: []
        }

        # custom user payloads
        slack_attachment[:fields] += options[:payload].map do |k, v|
          {
            title: k.to_s,
            value: v.to_s,
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
            title: 'Test Result',
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
        if git_author && should_add_payload[:git_author]
          if ENV['FASTLANE_SLACK_HIDE_AUTHOR_ON_SUCCESS'] && options[:success]
            # We only show the git author if the build failed
          else
            slack_attachment[:fields] << {
              title: 'Git Author',
              value: git_author,
              short: true
            }
          end
        end

        # last_git_commit
        if last_git_commit && should_add_payload[:last_git_commit]
          slack_attachment[:fields] << {
            title: 'Git Commit',
            value: last_git_commit,
            short: false
          }
        end

        result = notifier.ping '',
                               icon_url: 'https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png',
                               attachments: [slack_attachment]

        unless result.code.to_i == 200
          Helper.log.debug result
          raise 'Error pushing Slack message, maybe the integration has no permission to post on this channel? Try removing the channel parameter in your Fastfile.'.red
        else
          Helper.log.info 'Successfully sent Slack notification'.green
        end
      end

      def self.description
        "Send a success/error message to your Slack group"
      end

      def self.available_options
        [
          ['message', 'The message that should be displayed on Slack. This supports the standard Slack markup language'],
          ['channel', '#channel or @username'],
          ['success', 'Success or error?'],
          ['payload', 'Add additional information to this post. payload must be a hash containg any key with any value'],
          ['default_payloads', 'Remove some of the default payloads. More information about the available payloads GitHub']
        ]
      end

      def self.author
        "KrauseFx"
      end
    end
  end
end
