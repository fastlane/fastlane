module Fastlane
  module Actions
    class EnvironmentVariableAction < Action
      def self.run(params)
        values_to_set = params[:set]
        value_to_get = params[:get]
        value_to_remove = params[:remove]

        # clear out variables that were removed
        ENV[value_to_remove] = nil unless value_to_remove.nil?

        # if we have to set variables, do that now
        unless values_to_set.nil?
          values_to_set.each do |key, value|
            ENV[key] = value
          end
        end

        # finally, get the variable we requested
        return ENV[value_to_get] unless value_to_get.nil?

        # if no variable is requested, just return empty string
        return ""
      end

      def self.author
        "taquitos"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :set,
                                       env_name: 'FL_ENVIRONMENT_VARIABLE_SET',
                                       description: 'Set the environment variables named',
                                       optional: true,
                                       type: Hash),
          FastlaneCore::ConfigItem.new(key: :get,
                                       env_name: 'FL_ENVIRONMENT_VARIABLE_GET',
                                       description: 'Get the environment variable named',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :remove,
                                       env_name: 'FL_ENVIRONMENT_VARIABLE_REMOVE',
                                       description: 'Remove the environment variable named',
                                       optional: true)
        ]
      end

      def self.description
        "Sets/gets env vars for Fastlane.swift. Don't use in ruby, use `ENV[key] = val`"
      end

      def self.step_text
        nil
      end

      def self.category
        :misc
      end

      def self.return_type
        :string
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
