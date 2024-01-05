module Fastlane
  module Actions
    class EnsureEnvVarsAction < Action
      def self.run(params)
        variables = params[:env_vars]
        missing_variables = variables.select { |variable| ENV[variable].to_s.strip.empty? }

        UI.user_error!("Missing environment variable(s) '#{missing_variables.join('\', \'')}'") unless missing_variables.empty?

        is_one = variables.length == 1
        UI.success("Environment variable#{is_one ? '' : 's'} '#{variables.join('\', \'')}' #{is_one ? 'is' : 'are'} set!")
      end

      def self.description
        'Raises an exception if the specified env vars are not set'
      end

      def self.details
        'This action will check if some environment variables are set.'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :env_vars,
                                       description: 'The environment variables names that should be checked',
                                       type: Array,
                                       verify_block: proc do |value|
                                         UI.user_error!('Specify at least one environment variable name') if value.empty?
                                       end)
        ]
      end

      def self.authors
        ['revolter']
      end

      def self.example_code
        [
          'ensure_env_vars(
            env_vars: [\'GITHUB_USER_NAME\', \'GITHUB_API_TOKEN\']
          )'
        ]
      end

      def self.category
        :misc
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
