module Fastlane
  module Actions
    # To share this integration with the other fastlane users:
    # - Fork https://github.com/KrauseFx/fastlane
    # - Clone the forked repository
    # - Move this integration into lib/fastlane/actions
    # - Commit, push and submit the pull request

    class PubuAction < Action
      def self.run(params)
        url = ENV['PUBU_URL']
        message = params[:message].to_s
        pubuayload = buildPayload(message,params)
        sendPubu(url,pubuayload)
        raise "`PUBU_URL` lost  please set ENV first`".red unless url
      end



      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :message,
                                       description: "The message will displayed on PubuIM",
                                       optional: true),

          FastlaneCore::ConfigItem.new(key: :pubuUrl,
                                       env_name: "PUBU_URL",
                                       description: "PubuIM services url", #todo add doc url here
                                       optional: true,
                                       verify_block: proc do |value|
                                          raise "Invalid PUBU_URL" unless value.start_with? "https://hooks.pubu.im/services/"
                                       end),
          FastlaneCore::ConfigItem.new(key: :payload,
                                      description: "Add additional information to this post. payload must be a hash containg any key with any value",
                                      default_value: {},
                                      is_string: false),
          FastlaneCore::ConfigItem.new(key: :color,
                                      description: "Was this color we support [warning|info|primary|error|muted|success]",
                                      optional: true,
                                      default_value: "info") ]
      end


      def self.buildPayload(message,params)
        require 'json'
        return {
              "text"=>message,
              "payload" => params[:payload].to_json,
              "color" => params[:color]
          }
      end

      def self.sendPubu(url,payload)
        require 'net/http'
        Net::HTTP.post_form(URI(url),payload)
      end


      def self.description
        "Send Notification to Pubu.IM"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "You can use Pubu to Notification"
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Pubu.IM"]
      end

      def self.is_supported?(platform)
          true
      end
    end
  end
end
