module Fastlane
  module Actions
    def self.git_log_between(pretty_format, from, to)
      Actions.sh("git log --pretty=\"#{pretty_format}\" #{from.shellescape}...#{to.shellescape}", log: false).chomp
    rescue
      nil
    end

    def self.last_git_tag_name(match_lightweight = true)
      command = ['git describe']
      command << '--tags' if match_lightweight
      command << '--abbrev=0'
      Actions.sh(command.join(' '), log: false).chomp
    rescue
      nil
    end

    def self.last_git_commit_dict
      return nil if last_git_commit_formatted_with('%an').nil?

      {
          author: last_git_commit_formatted_with('%an'),
          message: last_git_commit_formatted_with('%B')
      }
    end

    # Gets the last git commit information formatted into a String by the provided
    # pretty format String. See the git-log documentation for valid format placeholders
    def self.last_git_commit_formatted_with(pretty_format)
      Actions.sh("git log -1 --pretty=#{pretty_format}", log: false).chomp
    rescue
      nil
    end

    # Get the author email of the last git commit
    # <b>DEPRECATED:</b> Use <tt>git_author_email</tt> instead.
    def self.git_author
      Helper.log.warn '`git_author` is deprecated. Please use `git_author_email` instead.'.red
      git_author_email
    end

    # Get the author email of the last git commit
    def self.git_author_email
      s = last_git_commit_formatted_with('%ae')
      return s if s.to_s.length > 0
      return nil
    end

    # Returns the unwrapped subject and body of the last commit
    # <b>DEPRECATED:</b> Use <tt>last_git_commit_message</tt> instead.
    def self.last_git_commit
      Helper.log.warn '`last_git_commit` is deprecated. Please use `last_git_commit_message` instead.'.red
      last_git_commit_message
    end

    # Returns the unwrapped subject and body of the last commit
    def self.last_git_commit_message
      s = (last_git_commit_formatted_with('%B') || "").strip
      return s if s.to_s.length > 0
      nil
    end

    # Returns the current git branch - can be replaced using the environment variable `GIT_BRANCH`
    def self.git_branch
      return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH'].to_s.length > 0 # set by Jenkins
      s = Actions.sh("git rev-parse --abbrev-ref HEAD", log: false).chomp
      return s.to_s.strip if s.to_s.length > 0
      nil
    rescue
      nil
    end
  end
end
