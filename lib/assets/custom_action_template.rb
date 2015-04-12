module Fastlane
  module Actions
    module SharedValues
      [[NAME_UP]]_CUSTOM_VALUE = :[[NAME_UP]]_CUSTOM_VALUE
    end

    class [[NAME_CLASS]] < Action
      def self.run(params)
        puts "My Ruby Code!"
        # puts "Parameter Path: #{params[:first]}"
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
        # The environment variable (last parameters) is optional, remove it if you don't need it
        # You can add as many parameters as you want
        [
          ['path', 'Describe what this parameter is useful for', 'ENVIRONMENT_VARIABLE_NAME'],
          ['second', 'Describe what this parameter is useful for']
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
        '[Your GitHub Name]'
      end
    end
  end
end