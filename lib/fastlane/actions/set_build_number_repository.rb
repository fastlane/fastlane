module Fastlane
  module Actions
    module SharedValues
    end

    class SetBuildNumberRepositoryAction < Action
      def self.is_supported?(platform)
        platform == :ios
      end

      def self.is_svn?
        begin
          Actions.sh 'svn info'
          return true
        rescue
          return false
        end
      end

      def self.is_git?
        begin
          Actions.sh 'git rev-parse HEAD'
          return true
        rescue
          return false
        end
      end

      def self.is_git_svn?
        begin
          Actions.sh 'git svn info'
          return true
        rescue
          return false
        end
      end

      def self.run(params)
         begin

          if is_svn?
            Helper.log.info "Detected repo: svn"
            command = 'svn info | grep Revision | egrep -o "[0-9]+"'
          elsif is_git_svn?
            Helper.log.info "Detected repo: git-svn"
            command = 'git svn info | grep Revision | egrep -o "[0-9]+"'
          elsif is_git?
            Helper.log.info "Detected repo: git"
            command = 'git rev-parse --short HEAD'
          else
            raise "No repository detected"
          end

          build_number = Actions.sh command

          Fastlane::Actions::IncrementBuildNumberAction.run(build_number:build_number)

        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Set the build number from the current repository"
      end

      def self.available_options
        [
        ]
      end

      def self.output
        [
        ]
      end

      def self.author
        'pbrooks'
      end
    end
  end
end
