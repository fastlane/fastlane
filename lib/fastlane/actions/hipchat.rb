module Fastlane
  module Actions
    module SharedValues

    end

    class HipchatAction
      def self.run(params)
        options = { message: '',
                    success: true,
                    room: nil
                  }.merge(params.first || {})

        require 'hipchat'

        api_token = ENV["HIPCHAT_API_TOKEN"]

        unless api_token
          Helper.log.fatal "Please add 'ENV[\"HIPCHAT_API_TOKEN\"] = \"your token\"' to your Fastfile's `before_all` section.".red
          raise "No HIPCHAT_API_TOKEN given.".red
        end

        client = HipChat::Client.new(api_token, :api_version => 'v2')
        color = (options[:success] ? 'green' : 'red')
        client[options[:room]].send('fastlane',options[:message], :message_format => 'text', :color => color)

      end
    end
  end
end
