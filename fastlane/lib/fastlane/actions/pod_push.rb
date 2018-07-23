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

        if params[:verbose]
          command << "--verbose"
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
                                         is_string: false,
                                         default_value: false),
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: "The Podspec you want to push",
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                         UI.user_error!("File must be a `.podspec` or `.podspec.json`") unless value.end_with?(".podspec", ".podspec.json")
                                       end),
          FastlaneCore::ConfigItem.new(key: :repo,
                                       description: "The repo you want to push. Pushes to Trunk by default",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :allow_warnings,
                                       description: "Allow warnings during pod push",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :use_libraries,
                                       description: "Allow lint to use static libraries to install the spec",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :sources,
                                       description: "The sources of repos you want the pod spec to lint with, separated by commas",
                                       optional: true,
                                       is_string: false,
                                       type: Array,
                                       verify_block: proc do |value|
                                         UI.user_error!("Sources must be an array.") unless value.kind_of?(Array)
                                       end),
          FastlaneCore::ConfigItem.new(key: :swift_version,
                                       description: "The SWIFT_VERSION that should be used to lint the spec. This takes precedence over a .swift-version file",
                                       optional: true,
                                       is_string: false),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "Show more debugging information",
                                       optional: true,
                                       is_string: false,
                                       default_value: false)
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
