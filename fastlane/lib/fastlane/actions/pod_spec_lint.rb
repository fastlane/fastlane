module Fastlane
  module Actions
    class PodSpecLintAction < Action
      def self.run(params)
        command = []

        command << "bundle exec" if params[:use_bundle_exec] && shell_out_should_use_bundle_exec?

        command << "pod spec lint"

        if params[:sources]
          sources = params[:sources].join(",")
          command << "--sources='#{sources}'"
        end

        if params[:subspec]
          subspec = params[:subspec]
          command << "--subspec='#{subspec}'"
        end
        
        if params[:swift_version]
          swift_version = params[:swift_version]
          command << "--swift-version=#{swift_version}"
        end

        command << "--allow-warnings" if params[:allow_warnings]
        command << "--verbose" if params[:verbose]
        command << "--quick" if params[:quick]
        command << "--use-libraries" if params[:use_libraries]
        command << "--fail-fast" if params[:fail_fast]
        command << "--private" if params[:private]
        
        
        result = Actions.sh(command.join(' '))
        UI.success("Pod spec lint Successfully ⬆️ ")
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Pod spec lint"
      end

      def self.details
        "Validates `NAME.podspec`. If a `DIRECTORY` is provided, it validates the podspec
        files found, including subfolders. In case the argument is omitted, it defaults
        to the current working dir."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                       description: "Use bundle exec when there is a Gemfile presented",
                                       is_string: false,
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :quick,
                                       description: "Lint skips checks that would require to download and build the spec",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                       description: "Lint validates even if warnings are present",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :subspec,
                                       description: "Lint validates only the given subspec",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                          UI.user_error!("Subspec must be a string.") unless value.kind_of?(String)
                                       end),
          FastlaneCore::ConfigItem.new(key: :fail_fast,
                                       description: "Lint stops on the first failing platform or subspec",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :use_libraries,
                                       description: "Lint uses static libraries to install the spec",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :sources,
                                       description: "he sources from which to pull dependent pods (defaults to https://github.com/CocoaPods/Specs.git). Multiple sources must be comma-delimited",
                                       optional: true,
                                       is_string: false,
                                       verify_block: proc do |value|
                                          UI.user_error!("Sources must be an array.") unless value.kind_of?(Array)
                                       end),
          FastlaneCore::ConfigItem.new(key: :private,
                                       description: "Lint skips checks that apply only to public specs",
                                       is_string: false,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :swift_version,
                                       description: "The SWIFT_VERSION that should be used to lint the spec. This takes precedence over a .swift-version file",
                                       optional: true,
                                       is_string: true,
                                       verify_block: proc do |value|
                                          UI.user_error!("Swift version must be a string.") unless value.kind_of?(String)
                                       end),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "Allow output detail in console",
                                       optional: true,
                                       is_string: false),
        ]
      end

      def self.output
      end

      def self.return_value
        nil
      end

      def self.authors
        ["GongCheng"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'pod_spec_lint',
          '# Show more debugging information during pod spec lint
          pod_spec_lint(verbose: true)',
          '# Allow warnings during pod spec lint
          pod_spec_lint(allow_warnings: true)',
          '# If the podspec has a dependency on another private pod, then you will have to supply the sources
          pod_spec_lint(sources: ["https://github.com/MyGithubPage/Specs", "https://github.com/CocoaPods/Specs"])'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
