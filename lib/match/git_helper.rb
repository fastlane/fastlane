module Match
  class GitHelper
    def self.clone(git_url)
      return @dir if @dir

      @dir = Dir.mktmpdir
      command = "git clone '#{git_url}' '#{@dir}' --depth 1"
      Helper.log.info "Cloning remote git repo..."
      FastlaneCore::CommandExecutor.execute(command: command, 
                                          print_all: $verbose, 
                                      print_command: $verbose)

      raise "Error cloning repo, make sure you have access to it '#{git_url}'".red unless File.directory?(@dir)

      copy_readme(@dir)

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

    def self.commit_changes(path, message)
      Dir.chdir(path) do
        return if `git status`.include?("nothing to commit")
        commands = []
        commands << "git add -A"
        commands << "git commit -m '#{message}'"
        commands << "git push origin master"

        commands.each do |command|
          FastlaneCore::CommandExecutor.execute(command: command, 
                                              print_all: $verbose, 
                                          print_command: $verbose)
        end
      end
    end

    # Copies the README.md into the git repo
    def self.copy_readme(directory)
      template = File.read("#{Helper.gem_path('match')}/lib/assets/READMETemplate.md")
      File.write(File.join(directory, "README.md"), template)
    end
  end
end
