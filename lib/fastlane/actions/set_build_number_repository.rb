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

      def self.git_initial_commit
        Actions.sh('git rev-list --max-parents=0 --abbrev-commit HEAD').chomp
      end

      def self.git_tags_matching(matching)
        tags = Actions.sh('git show-ref --tags').split("\n")
        tags = tags.map { |tag| tag.split(" ") }
        if matching
          tags = tags.select { |shaTag| shaTag[1].start_with? "refs/tags/#{matching}" }
        end
        tags.map { |shaTag| shaTag[0] }
      end

      def self.git_diverging_commit_matching(matching)
        list = git_tags_matching(matching)
        if list.empty?
          git_initial_commit
        else
          list.last.split(" ").first
        end
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
          tagPrefix = params[:use_git_counts_matching_tag]
          if tagPrefix
            major = git_tags_matching(tagPrefix).count
            minor = git_commit_count_between(git_diverging_commit_matching(tagPrefix))
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
          FastlaneCore::ConfigItem.new(key: :use_git_counts_matching_tag,
                                       env_name: "USE_GIT_COUNTS_MATCHING_TAG",
                                       description: "Use the number of matching tags as the major version, number of commits since last matching tag as minor version, and a numeric SHA as the patch version",
                                       optional: true,
                                       is_string: true,
                                       default_value: nil)
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
