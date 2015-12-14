module Match
  class GitHelper
    def self.clone(git_url)
      return @dir if @dir

      @dir = Dir.mktmpdir
      command = "git clone '#{git_url}' '#{@dir}' --depth 1"
      UI.message "Cloning remote git repo..."
      FastlaneCore::CommandExecutor.execute(command: command,
                                          print_all: $verbose,
                                      print_command: $verbose)

      raise "Error cloning repo, make sure you have access to it '#{git_url}'".red unless File.directory?(@dir)

      copy_readme(@dir)
      Encrypt.new.decrypt_repo(path: @dir, git_url: git_url)

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

    def self.commit_changes(path, message, git_url)
      Dir.chdir(path) do
        return if `git status`.include?("nothing to commit")

        Encrypt.new.encrypt_repo(path: path, git_url: git_url)

        commands = []
        commands << "git add -A"
        commands << "git commit -m '#{message}'"
        commands << "git push origin master"

        UI.message "Pushing changes to remote git repo..."

        commands.each do |command|
          FastlaneCore::CommandExecutor.execute(command: command,
                                              print_all: $verbose,
                                          print_command: $verbose)
        end
      end
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
