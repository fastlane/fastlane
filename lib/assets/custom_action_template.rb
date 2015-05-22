module Fastlane
  module Actions
    module SharedValues
      [[NAME_UP]]_CUSTOM_VALUE = :[[NAME_UP]]_CUSTOM_VALUE
    end

    class [[NAME_CLASS]] < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        Helper.log.info "Parameter API Token: #{params[:api_token]}"

        # sh "shellcommand ./path"

        # Actions.lane_context[SharedValues::[[NAME_UP]]_CUSTOM_VALUE] = "my_val"
      end



      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "A short description with <= 80 characters of what this action does"
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :api_token,
                                       env_name: "FL_[[NAME_UP]]_API_TOKEN", # The name of the environment variable
                                       description: "API Token for [[NAME_CLASS]]", # a short description of this parameter
                                       verify_block: Proc.new do |value|
                                          raise "No API token for [[NAME_CLASS]] given, pass using `api_token: 'token'`".red unless (value and not value.empty?)
                                       end),
          FastlaneCore::ConfigItem.new(key: :development,
                                       env_name: "FL_[[NAME_UP]]_DEVELOPMENT",
                                       description: "Create a development certificate instead of a distribution one",
                                       is_string: false, # true: verifies the input is a string, false: every kind of value
                                       default_value: false) # the default value if the user didn't provide one
        ]
      end

      def self.output
        # Define the shared values you are going to provide
        # Example
        [
          ['[[NAME_UP]]_CUSTOM_VALUE', 'A description of what this value contains']
        ]
      end

      def self.author
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        '[Your GitHub/Twitter Name]'
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