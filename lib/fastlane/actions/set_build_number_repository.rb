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

      def self.git_tag_count
        tags = Actions.sh('git log --simplify-by-decoration --decorate --pretty=oneline HEAD | grep "tag:"').shellsplit
        tags.count
      rescue
        0
      end

      def self.git_commit_count_reference_point
        Actions.sh('git describe --tags --abbrev=0 $(git rev-list --tags --max-count=1 HEAD)').chomp
      rescue
        # No tags, return first sha
        Actions.sh('git rev-list --max-parents=0 --abbrev-commit HEAD').chomp
      end

      def self.git_commit_count_between(commitA, commitB = "HEAD")
        Actions.sh("git rev-list #{commitA}..#{commitB} --count").chomp
      end

      def self.git_abbrev_last_commit
        Actions.sh('git rev-list --max-count=1 --abbrev=0 --abbrev-commit HEAD').chomp
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
          if params[:use_git_counts_from_tag]
            major = git_tag_count
            minor = git_commit_count_between(git_commit_count_reference_point)
            patch = git_abbrev_last_commit.to_i(16)
            build_number = "#{major}.#{minor}.#{patch}"
          else
            command = 'git rev-parse --short HEAD'
          end
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
        if build_number.nil?
          build_number = Actions.sh command
        end

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
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :use_git_counts_from_tag,
                                       env_name: "USE_GIT_COUNTS_FROM_TAG",
                                       description: "Use the number of tags as the major version, number of commits since last tag as minor version, and a numeric SHA as the patch version",
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
