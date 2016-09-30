module Fastlane
  module Actions
    module SharedValues
    end

    class SetBuildNumberRepositoryAction < Action
      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end

      def self.run(params)
        build_number = Fastlane::Actions::GetBuildNumberRepositoryAction.run(
          use_hg_revision_number: params[:use_hg_revision_number]
        )

        Fastlane::Actions::IncrementBuildNumberAction.run(build_number: build_number)
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
          "There is an option, `:use_hg_revision_number`, which allows to use mercurial revision number instead of hash"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :use_hg_revision_number,
                                       env_name: "USE_HG_REVISION_NUMBER",
                                       description: "Use hg revision number instead of hash (ignored for non-hg repos)",
                                       optional: true,
                                       is_string: false,
                                       default_value: false)
        ]
      end

      def self.authors
        ["pbrooks", "armadsen"]
      end

      def self.example_code
        [
          'set_build_number_repository'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
