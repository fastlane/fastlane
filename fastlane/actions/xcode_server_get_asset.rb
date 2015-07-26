module Fastlane
  module Actions
    module SharedValues
      XCODE_SERVER_GET_ASSET_CUSTOM_VALUE = :XCODE_SERVER_GET_ASSET_CUSTOM_VALUE
    end

    class XcodeServerGetAssetAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        # Helper.log.info "Parameter API Token: #{params[:api_token]}"

        require 'excon'
        Excon.defaults[:ssl_verify_peer] = false # for self-signed certificates
        
        response = Excon.get("https://127.0.0.1:20343/api/bots")
        
        require 'pry'
        binding.pry

        Helper.log.info response

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::XCODE_SERVER_GET_ASSET_CUSTOM_VALUE] = "my_val"
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.details
        # Optional:
        # this is your change to provide a more detailed description of this action
        "You can use this action to do cool things..."
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          # FastlaneCore::ConfigItem.new(key: :api_token,
          #                              env_name: "FL_XCODE_SERVER_GET_ASSET_API_TOKEN", # The name of the environment variable
          #                              description: "API Token for XcodeServerGetAssetAction", # a short description of this parameter
          #                              verify_block: Proc.new do |value|
          #                                 raise "No API token for XcodeServerGetAssetAction given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
          #                              end),
          # FastlaneCore::ConfigItem.new(key: :development,
          #                              env_name: "FL_XCODE_SERVER_GET_ASSET_DEVELOPMENT",
          #                              description: "Create a development certificate instead of a distribution one",
          #                              is_string: false, # true: verifies the input is a string, false: every kind of value
          #                              default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['XCODE_SERVER_GET_ASSET_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["Your GitHub/Twitter Name"]
      end

      def self.is_supported?(platform)
        # you can do things like
        # 
        #  true
        # 
        #  platform == :ios
        # 
        #  [:ios, :mac].include?platform
        # 

        platform == :ios
      end
    end
  end
end