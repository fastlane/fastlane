module Fastlane
  module Actions
    class CocoapodsAction < Action
      def self.run(params)
        Actions.verify_gem!('cocoapods')
        cmd = []

        unless params[:podfile].nil?
          if params[:podfile].end_with?('Podfile')
            podfile_folder = File.dirname(params[:podfile])
          else
            podfile_folder = params[:podfile]
          end
          cmd << ["cd '#{podfile_folder}' &&"]
        end

        cmd << ['bundle exec'] if params[:use_bundle_exec] && shell_out_should_use_bundle_exec?
        cmd << ['pod install']

        cmd << '--no-clean' unless params[:clean]
        cmd << '--no-integrate' unless params[:integrate]
        cmd << '--repo-update' if params[:repo_update]
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
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :integrate,
                                       env_name: "FL_COCOAPODS_INTEGRATE",
                                       description: "Integrate the Pods libraries into the Xcode project(s)",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :repo_update,
                                       env_name: "FL_COCOAPODS_REPO_UPDATE",
                                       description: "Run `pod repo update` before install",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :silent,
                                       env_name: "FL_COCOAPODS_SILENT",
                                       description: "Execute command without logging output",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       env_name: "FL_COCOAPODS_VERBOSE",
                                       description: "Show more debugging information",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :ansi,
                                       env_name: "FL_COCOAPODS_ANSI",
                                       description: "Show output with ANSI codes",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                       env_name: "FL_COCOAPODS_USE_BUNDLE_EXEC",
                                       description: "Use bundle exec when there is a Gemfile presented",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :podfile,
                                       env_name: "FL_COCOAPODS_PODFILE",
                                       description: "Explicitly specify the path to the Cocoapods' Podfile. You can either set it to the Podfile's path or to the folder containing the Podfile file",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find Podfile") unless File.exist?(value) || Helper.test?
                                       end)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.authors
        ["KrauseFx", "tadpol", "birmacher", "Liquidsoul"]
      end

      def self.details
        "If you use [CocoaPods](http://cocoapods.org) you can use the `cocoapods` integration to run `pod install` before building your app."
      end

      def self.example_code
        [
          'cocoapods',
          'cocoapods(
            clean: true,
            podfile: "./CustomPodfile"
          )'
        ]
      end

      def self.category
        :building
      end
    end
  end
end
