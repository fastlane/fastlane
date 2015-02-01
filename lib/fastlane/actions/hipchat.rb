module Fastlane
  module Actions
    module SharedValues

    end

    class HipchatAction
      def self.run(params)
        options = { message: '',
                    success: true,
                    channel: nil
                  }.merge(params.first || {})

        require 'hipchat'

        api_token = ENV["HIPCHAT_API_TOKEN"]

        unless api_token
          Helper.log.fatal "Please add 'ENV[\"HIPCHAT_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.".red
          raise "No HIPCHAT_API_TOKEN given.".red
        end

        client = HipChat::Client.new(api_token, :api_version => 'v2')
        channel = options[:channel]
        color = (options[:success] ? 'green' : 'red')

        if channel.to_s.start_with?('@')
          #private message
          #currently hipchat-rb release wrapper doesn´t allow to send private html message we have to send the raw message
          channel.slice!(0)
          client.user(channel).send(options[:message])
        else
          #room message
          message = "<table><tr><td><img src=\"https://s3-eu-west-1.amazonaws.com/fastlane.tools/fastlane.png\" style=\"width:50px;height:auto\"></td><td>" + options[:message] + "</td></tr></table>"
          client[channel].send('fastlane',message, :message_format => 'html', :color => color)
        end

      end
    end
  end
end
