module Fastlane
  module Actions
    class CocoapodsAction < Action
      def self.run(params)
        cmd = []

        cmd << ['bundle exec'] if File.exists?('Gemfile') && params[:use_bundle_exec]
        cmd << ['pod install']

        cmd << '--no-clean' unless params[:clean]
        cmd << '--no-integrate' unless params[:integrate]
        cmd << '--no-repo-update' unless params[:repo_update]
        cmd << '--silent' if params[:silent]
        cmd << '--verbose' if params[:verbose]
        cmd << '--no-ansi' unless params[:ansi]

        Actions.sh(cmd.join(' '))
      end

      def self.description
        "Runs `pod install` for the project"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :clean,
                                       env_name: "FL_COCOAPODS_CLEAN",
                                       description: "Remove SCM directories",
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :integrate,
                                       env_name: "FL_COCOAPODS_INTEGRATE",
                                       description: "Integrate the Pods libraries into the Xcode project(s)",
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :repo_update,
                                       env_name: "FL_COCOAPODS_REPO_UPDATE",
                                       description: "Run `pod repo update` before install",
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :silent,
                                       env_name: "FL_COCOAPODS_SILENT",
                                       description: "Show nothing",
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_COCOAPODS_VERBOSE",
                                       description: "Show more debugging information",
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :ansi,
                                       env_name: "FL_COCOAPODS_ANSI",
                                       description: "Show output with ANSI codes",
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                       env_name: "FL_COCOAPODS_USE_BUNDLE_EXEC",
                                       description: "Use bundle exec when there is a Gemfile presented",
                                       is_string: false,
                                       default_value: true),
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?platform
      end

      def self.authors
        ["KrauseFx", "tadpol", "birmacher"]
      end
    end
  end
end
#  vim: set et sw=2 ts=2 :
