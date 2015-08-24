module Fastlane
  module Actions
    # Get the author name of the last git commit
    def self.git_author
      s = `git log --name-status HEAD^..HEAD`
      s = s.match(/Author:.*<(.*)>/)[1]
      return s if s.to_s.length > 0
      return nil
    rescue
      return nil
    end

    def self.last_git_commit
      s = `git log -1 --pretty=%B`.strip
      return s if s.to_s.length > 0
      nil
    end

    # Returns the current git branch - can be replaced using the environment variable `GIT_BRANCH`
    def self.git_branch
      return ENV['GIT_BRANCH'] if ENV['GIT_BRANCH'].to_s.length > 0 # set by Jenkins
      s = `git rev-parse --abbrev-ref HEAD`
      return s.to_s.strip if s.to_s.length > 0
      nil
    end
  end
end
