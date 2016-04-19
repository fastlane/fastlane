module Fastlane
  module Actions
    class DangerAction < Action
      def self.run(params)
        Actions.verify_gem!('danger')
        cmd = []

        cmd << ['bundle exec'] if File.exist?('Gemfile') && params[:use_bundle_exec]
        cmd << ['danger']

        Actions.sh(cmd.join(' '))
      end

      def self.description
        "Runs `danger` for the project"
      end

      def self.details
        "More information: https://github.com/danger/danger"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                       env_name: "FL_DANGER_USE_BUNDLE_EXEC",
                                       description: "Use bundle exec when there is a Gemfile presented",
                                       is_string: false,
                                       default_value: true)
        ]
      end

      def self.is_supported?(platform)
        true
      end

      def self.authors
        ["KrauseFx"]
      end
    end
  end
end
