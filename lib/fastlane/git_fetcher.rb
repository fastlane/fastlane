require 'tmpdir'

module Fastlane
  class GitFetcher
    attr_accessor :clone_folder

    # Clones a git repo into a temporary directory
    # @param url: The URL to clone
    # @param branch: The branch to check out
    # @param path: The path to check out. If it's nil, everything will be checked out
    def clone(url: nil, branch: 'HEAD', path: nil)
      # Checkout the repo
      repo_name = url.split("/").last
      tmp_path = Dir.mktmpdir("fl_clone")
      self.clone_folder = File.join(tmp_path, repo_name)

      branch_option = ""
      branch_option = "--branch #{branch}" if branch != 'HEAD'

      clone_command = "git clone '#{url}' '#{self.clone_folder}' --depth 1 -n #{branch_option}"

      UI.message "Cloning remote git repo..."
      Actions.sh(clone_command)

      Dir.chdir(self.clone_folder) do
        if path
          Actions.sh("git checkout #{branch} '#{path}'")
        else
          Actions.sh("git checkout #{branch}")
        end
      end

      return self.clone_folder
    end

    # Clears the temporary files
    def clear
      if Dir.exist?(self.clone_folder)
        # We want to re-clone if the folder already exists
        UI.message "Clearing the git repo..."
        FileUtils.rm_rf(File.expand_path('..', self.clone_folder))
      end
    end
  end
end
