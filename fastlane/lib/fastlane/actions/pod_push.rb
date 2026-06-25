module Fastlane
  module Actions
    class PodPushAction < Action
      def self.run(params)
        command = []

        command << "bundle exec" if params[:use_bundle_exec] && shell_out_should_use_bundle_exec?

        if params[:repo]
          repo = params[:repo]
          command << "pod repo push #{repo}"
        else
          command << 'pod trunk push'
        end

        if params[:path]
          command << "'#{params[:path]}'"
        end

        if params[:sources]
          sources = params[:sources].join(",")
          command << "--sources='#{sources}'"
        end

        if params[:swift_version]
          swift_version = params[:swift_version]
          command << "--swift-version=#{swift_version}"
        end

        if params[:allow_warnings]
          command << "--allow-warnings"
        end

        if params[:use_libraries]
          command << "--use-libraries"
        end

        if params[:skip_import_validation]
          command << "--skip-import-validation"
        end

        if params[:skip_tests]
          command << "--skip-tests"
        end

        if params[:use_json]
          command << "--use-json"
        end

        if params[:verbose]
          command << "--verbose"
        end

        if params[:use_modular_headers]
          command << "--use-modular-headers"
        end

        if params[:synchronous]
          command << "--synchronous"
        end

        if params[:no_overwrite]
          command << "--no-overwrite"
        end

        if params[:local_only]
          command << "--local-only"
        end

        result = Actions.sh(command.join(' '))
        UI.success("Successfully pushed Podspec ⬆️ ")
        return result
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Push a Podspec to Trunk or a private repository"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_bundle_exec,
                                         description: "Use bundle exec when there is a Gemfile presented",
                                         type: Boolean,
                                         default_value: false,
                                         env_name: "FL_POD_PUSH_USE_BUNDLE_EXEC"),
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The Podspec you want to push",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                         UI.user_error!("File must be a `.podspec` or `.podspec.json`") unless value.end_with?(".podspec", ".podspec.json")
                                       end,
                                       env_name: "FL_POD_PUSH_PATH"),
          FastlaneCore::ConfigItem.new(key: :repo,
                                       description: "The repo you want to push. Pushes to Trunk by default",
                                       optional: true,
                                       env_name: "FL_POD_PUSH_REPO"),
          FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                       description: "Allow warnings during pod push",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_ALLOW_WARNINGS"),
          FastlaneCore::ConfigItem.new(key: :use_libraries,
                                       description: "Allow lint to use static libraries to install the spec",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_USE_LIBRARIES"),
          FastlaneCore::ConfigItem.new(key: :sources,
                                       description: "The sources of repos you want the pod spec to lint with, separated by commas",
                                       optional: true,
                                       type: Array,
                                       verify_block: proc do |value|
                                         UI.user_error!("Sources must be an array.") unless value.kind_of?(Array)
                                       end,
                                       env_name: "FL_POD_PUSH_SOURCES"),
          FastlaneCore::ConfigItem.new(key: :swift_version,
                                       description: "The SWIFT_VERSION that should be used to lint the spec. This takes precedence over a .swift-version file",
                                       optional: true,
                                       env_name: "FL_POD_PUSH_SWIFT_VERSION"),
          FastlaneCore::ConfigItem.new(key: :skip_import_validation,
                                       description: "Lint skips validating that the pod can be imported",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_SKIP_IMPORT_VALIDATION"),
          FastlaneCore::ConfigItem.new(key: :skip_tests,
                                       description: "Lint skips building and running tests during validation",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_SKIP_TESTS"),
          FastlaneCore::ConfigItem.new(key: :use_json,
                                       description: "Convert the podspec to JSON before pushing it to the repo",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_USE_JSON"),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "Show more debugging information",
                                       optional: true,
                                       type: Boolean,
                                       default_value: false,
                                       env_name: "FL_POD_PUSH_VERBOSE"),
          FastlaneCore::ConfigItem.new(key: :use_modular_headers,
                                       description: "Use modular headers option during validation",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_USE_MODULAR_HEADERS"),
          FastlaneCore::ConfigItem.new(key: :synchronous,
                                       description: "If validation depends on other recently pushed pods, synchronize",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_SYNCHRONOUS"),
          FastlaneCore::ConfigItem.new(key: :no_overwrite,
                                       description: "Disallow pushing that would overwrite an existing spec",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_NO_OVERWRITE"),
          FastlaneCore::ConfigItem.new(key: :local_only,
                                       description: "Does not perform the step of pushing REPO to its remote",
                                       optional: true,
                                       type: Boolean,
                                       env_name: "FL_POD_PUSH_LOCAL_ONLY")
        ]
      end

      def self.return_value
        nil
      end

      def self.authors
        ["squarefrog"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          '# If no path is supplied then Trunk will attempt to find the first Podspec in the current directory.
          pod_push',
          '# Alternatively, supply the Podspec file path
          pod_push(path: "TSMessages.podspec")',
          '# You may also push to a private repo instead of Trunk
          pod_push(path: "TSMessages.podspec", repo: "MyRepo")',
          '# If the podspec has a dependency on another private pod, then you will have to supply the sources you want the podspec to lint with for pod_push to succeed. Read more here - https://github.com/CocoaPods/CocoaPods/issues/2543.
          pod_push(path: "TMessages.podspec", repo: "MyRepo", sources: ["https://github.com/username/Specs", "https://github.com/CocoaPods/Specs"])'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
