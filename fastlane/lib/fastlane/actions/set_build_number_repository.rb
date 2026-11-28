module Fastlane
  module Actions
    module SharedValues
    end

    class SetBuildNumberRepositoryAction < Action
      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.run(params)
        build_number = Fastlane::Actions::GetBuildNumberRepositoryAction.run(
          use_hg_revision_number: params[:use_hg_revision_number]
        )

        Fastlane::Actions::IncrementBuildNumberAction.run(
          build_number: build_number,
          xcodeproj: params[:xcodeproj]
        )
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set the build number from the current repository"
      end

      def self.details
        [
          "This action will set the **build number** according to what the SCM HEAD reports.",
          "Currently supported SCMs are svn (uses root revision), git-svn (uses svn revision) and git (uses short hash) and mercurial (uses short hash or revision number).",
          "There is an option, `:use_hg_revision_number`, which allows to use mercurial revision number instead of hash."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_hg_revision_number,
                                       env_name: "USE_HG_REVISION_NUMBER",
                                       description: "Use hg revision number instead of hash (ignored for non-hg repos)",
                                       optional: true,
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                       env_name: "XCODEPROJ_PATH",
                                       description: "explicitly specify which xcodeproj to use",
                                       optional: true,
                                       verify_block: proc do |value|
                                         path = File.expand_path(value)
                                         UI.user_error!("Please pass the path to the project, not the workspace") if path.end_with?(".xcworkspace")
                                         UI.user_error!("Could not find Xcode project at #{path}") unless Helper.test? || File.exist?(path)
                                       end)
        ]
      end

      def self.authors
        ["pbrooks", "armadsen", "AndrewSB"]
      end

      def self.example_code
        [
          'set_build_number_repository',
          'set_build_number_repository(
            xcodeproj: "./path/to/MyApp.xcodeproj"
          )'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
