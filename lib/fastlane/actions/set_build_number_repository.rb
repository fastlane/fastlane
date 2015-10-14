module Fastlane
  module Actions
    module SharedValues
    end

    class SetBuildNumberRepositoryAction < Action
      def self.is_supported?(platform)
        platform == :ios
      end

      def self.is_svn?
        Actions.sh 'svn info'
        return true
      rescue
        return false
      end

      def self.is_git?
        Actions.sh 'git rev-parse HEAD'
        return true
      rescue
        return false
      end

      def self.is_git_svn?
        Actions.sh 'git svn info'
        return true
      rescue
        return false
      end

      def self.is_hg?
        Actions.sh 'hg status'
        return true
      rescue
        return false
      end

      def self.run(params)
        if is_svn?
          Helper.log.info "Detected repo: svn"
          command = 'svn info | grep Revision | egrep -o "[0-9]+"'
        elsif is_git_svn?
          Helper.log.info "Detected repo: git-svn"
          command = 'git svn info | grep Revision | egrep -o "[0-9]+"'
        elsif is_git?
          Helper.log.info "Detected repo: git"
          command = 'git rev-parse --short HEAD'
        elsif is_hg?
          Helper.log.info "Detected repo: hg"
          if params[:use_hg_revision_number]
            command = 'hg parent --template {rev}'
          else
            command = 'hg parent --template "{node|short}"'
          end
        else
          raise "No repository detected"
        end

        build_number = Actions.sh command

        Fastlane::Actions::IncrementBuildNumberAction.run(build_number: build_number)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set the build number from the current repository"
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

      def self.output
        [
        ]
      end

      def self.authors
        ["pbrooks", "armadsen"]
      end
    end
  end
end
