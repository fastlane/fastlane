module Match
  class GitHelper
    def self.clone(git_url, shallow_clone, manual_password: nil, skip_docs: false)
      return @dir if @dir

      @dir = Dir.mktmpdir

      UI.message "Cloning remote git repo..."
      opts = {path: @dir}
      opts[:depth] = 1 if shallow_clone
      Git.clone(git_url, ".", opts)

      UI.user_error!("Error cloning repo, make sure you have access to it '#{git_url}'") unless File.directory?(@dir)

      if !Helper.test? and GitHelper.match_version(@dir).nil? and manual_password.nil? and File.exist?(File.join(@dir, "README.md"))
        UI.important "Migrating to new match..."
        ChangePassword.update(params: { git_url: git_url,
                                 shallow_clone: shallow_clone },
                                          from: "",
                                            to: Encrypt.new.password(git_url))
        return self.clone(git_url, shallow_clone)
      end

      copy_readme(@dir) unless skip_docs
      Encrypt.new.decrypt_repo(path: @dir, git_url: git_url, manual_password: manual_password)

      return @dir
    end

    def self.generate_commit_message(params)
      # 'Automatic commit via fastlane'
      [
        "[fastlane]",
        "Updated",
        params[:app_identifier],
        "for",
        params[:type].to_s
      ].join(" ")
    end

    def self.match_version(workspace)
      path = File.join(workspace, "match_version.txt")
      if File.exist?(path)
        Gem::Version.new(File.read(path))
      end
    end

    def self.commit_changes(path, message, git_url)
      git = Git.open(path)

      # Avoid calling git.status if no branch exists
      return unless git.current_branch.nil? or git.status.any?

      Encrypt.new.encrypt_repo(path: path, git_url: git_url)
      File.write(File.join(path, "match_version.txt"), Match::VERSION) # unencrypted

      UI.message "Pushing changes to remote git repo..."
      git.add(all: true)
      git.commit("message")
      git.push(:origin, :master)

      FileUtils.rm_rf(path)
      @dir = nil
    end

    def self.clear_changes
      return unless @dir

      FileUtils.rm_rf(@dir)
      UI.success "🔒  Successfully encrypted certificates repo" # so the user is happy
      @dir = nil
    end

    # Copies the README.md into the git repo
    def self.copy_readme(directory)
      template = File.read("#{Helper.gem_path('match')}/lib/assets/READMETemplate.md")
      File.write(File.join(directory, "README.md"), template)
    end
  end
end
