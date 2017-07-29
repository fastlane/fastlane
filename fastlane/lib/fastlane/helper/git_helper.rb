module Fastlane
  module Actions
    GIT_MERGE_COMMIT_FILTERING_OPTIONS = [:include_merges, :exclude_merges, :only_include_merges].freeze

    def self.git_log_between(pretty_format, from, to, merge_commit_filtering, date_format = nil, ancestry_path)
      command = ['git log']
      command << "--pretty=\"#{pretty_format}\""
      command << "--date=\"#{date_format}\"" if date_format
      command << '--ancestry-path' if ancestry_path
      command << "#{from.shellescape}...#{to.shellescape}"
      command << git_log_merge_commit_filtering_option(merge_commit_filtering)
      Actions.sh(command.compact.join(' '), log: false).chomp
    rescue
      nil
    end

    def self.git_log_last_commits(pretty_format, commit_count, merge_commit_filtering, date_format = nil, ancestry_path)
      command = ['git log']
      command << "--pretty=\"#{pretty_format}\""
      command << "--date=\"#{date_format}\"" if date_format
      command << '--ancestry-path' if ancestry_path
      command << "-n #{commit_count}"
      command << git_log_merge_commit_filtering_option(merge_commit_filtering)
      Actions.sh(command.compact.join(' '), log: false).chomp
    rescue
      nil
    end

    def self.last_git_tag_name(match_lightweight = true, tag_match_pattern = nil)
      tag_pattern_param = tag_match_pattern ? "=#{tag_match_pattern.shellescape}" : ''

      command = ['git describe']
      command << '--tags' if match_lightweight
      command << "`git rev-list --tags#{tag_pattern_param} --max-count=1`"
      Actions.sh(command.compact.join(' '), log: false).chomp
    rescue
      nil
    end

    def self.last_git_commit_dict
      return nil if last_git_commit_formatted_with('%an').nil?

      {
          author: last_git_commit_formatted_with('%an'),
          message: last_git_commit_formatted_with('%B'),
          commit_hash: last_git_commit_formatted_with('%H'),
          abbreviated_commit_hash: last_git_commit_formatted_with('%h')
      }
    end

    # Gets the last git commit information formatted into a String by the provided
    # pretty format String. See the git-log documentation for valid format placeholders
    def self.last_git_commit_formatted_with(pretty_format, date_format = nil)
      command = ['git log -1']
      command << "--pretty=\"#{pretty_format}\""
      command << "--date=\"#{date_format}\"" if date_format
      Actions.sh(command.compact.join(' '), log: false).chomp
    rescue
      nil
    end

    # @deprecated Use <tt>git_author_email</tt> instead
    # Get the author email of the last git commit
    # <b>DEPRECATED:</b> Use <tt>git_author_email</tt> instead.
    def self.git_author
      UI.deprecated('`git_author` is deprecated. Please use `git_author_email` instead.')
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
      UI.important('`last_git_commit` is deprecated. Please use `last_git_commit_message` instead.')
      last_git_commit_message
    end

    # Returns the unwrapped subject and body of the last commit
    def self.last_git_commit_message
      s = (last_git_commit_formatted_with('%B') || "").strip
      return s if s.to_s.length > 0
      nil
    end

    # Get the hash of the last commit
    def self.last_git_commit_hash(short)
      format_specifier = short ? '%h' : '%H'
      string = last_git_commit_formatted_with(format_specifier).to_s
      return string unless string.empty?
      return nil
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

    private_class_method
    def self.git_log_merge_commit_filtering_option(merge_commit_filtering)
      case merge_commit_filtering
      when :exclude_merges
        "--no-merges"
      when :only_include_merges
        "--merges"
      when :include_merges
        nil
      end
    end
  end
end
