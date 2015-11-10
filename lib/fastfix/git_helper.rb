module Fastfix
  class GitHelper
    def self.clone(git_url)
      return @dir if @dir

      @dir = Dir.mktmpdir
      command = "git clone '#{git_url}' '#{@dir}' --depth 1"
      Helper.log.info "Cloning remote git repo..."
      Actions.sh(command)

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
          Action.sh(command)
        end
      end
    end
  end
end
