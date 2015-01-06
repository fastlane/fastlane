module Fastlane
  module Actions
    module SharedValues
      
    end

    def self.slack(params)
      options = { message: nil, 
                  success: true, 
                  channel: nil
                }.merge(params.first)
      
      execute_action("slack") do
        Dir.chdir("..") do # go up from the fastlane folder, to the project folder
          require 'slack-notifier'

          success = true

          color = (success ? 'good' : 'danger')
          options[:message] = Slack::Notifier::LinkFormatter.format(options[:message])

          url = ENV["SLACK_URL"]
          unless url
            Helper.log.fatal "Please add 'ENV[\"SLACK_URL\"] = \"https://hooks.slack.com/services/...\"' to your Fastfile's `before_all` section.".red
            raise "No SLACK_URL given.".red
          end

          notifier = Slack::Notifier.new url

          notifier.username = 'fastlane'
          notifier.channel  = "##{options[:channel]}" if options[:channel].to_s.length > 0
          notifier.channel = '#random'

          test_result = {
            fallback: options[:message],
            text: options[:message],
            color: color,
            fields: [
              {
                title: "Lane",
                value: Actions.lane_context[Actions::SharedValues::LANE_NAME],
                short: true
              },
              {
                title: "Test Result",
                value: (success ? "Success" : "Error"),
                short: true
              }
            ]
          }

          notifier.ping "", 
                        # icon_url: 'TODO',
                        attachments: [test_result]

          Helper.log.info "Successfully sent Slack notification"
        end
      end
    end
  end
end