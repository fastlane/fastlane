module Fastlane
  module Actions
    module SharedValues
      BUILD_NUMBER_REPOSITORY = :BUILD_NUMBER_REPOSITORY
    end

    class GetBuildNumberRepositoryAction < Action
      def self.is_svn?
        Actions.sh('svn info')
        return true
      rescue
        return false
      end

      def self.is_git?
        Actions.sh('git rev-parse HEAD')
        return true
      rescue
        return false
      end

      def self.is_git_svn?
        Actions.sh('git svn info')
        return true
      rescue
        return false
      end

      def self.is_hg?
        Actions.sh('hg status')
        return true
      rescue
        return false
      end

      def self.command(use_hg_revision_number)
        if is_svn?
          UI.message("Detected repo: svn")
          return 'svn info | grep Revision | egrep -o "[0-9]+"'
        elsif is_git_svn?
          UI.message("Detected repo: git-svn")
          return 'git svn info | grep Revision | egrep -o "[0-9]+"'
        elsif is_git?
          UI.message("Detected repo: git")
          return 'git rev-parse --short HEAD'
        elsif is_hg?
          UI.message("Detected repo: hg")
          if use_hg_revision_number
            return 'hg parent --template {rev}'
          else
            return 'hg parent --template "{node|short}"'
          end
        else
          UI.user_error!("No repository detected")
        end
      end

      def self.run(params)
        build_number = Action.sh(command(params[:use_hg_revision_number])).strip
        Actions.lane_context[SharedValues::BUILD_NUMBER_REPOSITORY] = build_number
        return build_number
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Get the build number from the current repository"
      end

      def self.details
        [
          "This action will get the **build number** according to what the SCM HEAD reports.",
          "Currently supported SCMs are svn (uses root revision), git-svn (uses svn revision), git (uses short hash) and mercurial (uses short hash or revision number).",
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
                                       default_value: false)
        ]
      end

      def self.output
        [
          ['BUILD_NUMBER_REPOSITORY', 'The build number from the current repository']
        ]
      end

      def self.return_value
        "The build number from the current repository"
      end

      def self.authors
        ["bartoszj", "pbrooks", "armadsen"]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'get_build_number_repository'
        ]
      end

      def self.category
        :source_control
      end
    end
  end
end
