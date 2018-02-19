require 'fileutils'

module Fastlane
  # Enable tab auto completion
  class AutoComplete
    # This method copies the tab auto completion scripts to the user's home folder,
    # while optionally adding custom commands for which to enable auto complete
    # @param [Array] options An array of all options (e.g. --custom fl)
    def self.execute(args, options)
      shell = ENV['SHELL']

      if shell.end_with?("fish")
        fish_completions_dir = "~/.config/fish/completions"

        if UI.interactive?
          confirm = UI.confirm("This will copy a fish script into #{fish_completions_dir} that provides the command tab completion. If the directory does not exist it will be created. Sound good?")
          return unless confirm
        end

        fish_completions_dir = File.expand_path(fish_completions_dir)
        FileUtils.mkdir_p(fish_completions_dir)

        completion_script_path = File.join(Fastlane::ROOT, 'lib', 'assets', 'completions', 'completion.fish')
        final_completion_script_path = File.join(fish_completions_dir, 'fastlane.fish')

        FileUtils.cp(completion_script_path, final_completion_script_path)

        UI.success("Copied! You can now use tab completion for lanes")
      else
        fastlane_conf_dir = "~/.fastlane"

        if UI.interactive?
          confirm = UI.confirm("This will copy a shell script into #{fastlane_conf_dir} that provides the command tab completion. Sound good?")
          return unless confirm
        end

        # create the ~/.fastlane directory
        fastlane_conf_dir = File.expand_path(fastlane_conf_dir)
        FileUtils.mkdir_p(fastlane_conf_dir)

        # then copy all of the completions files into it from the gem
        completion_script_path = File.join(Fastlane::ROOT, 'lib', 'assets', 'completions')
        FileUtils.cp_r(completion_script_path, fastlane_conf_dir)

        custom_commands = options.custom.to_s.split(',')

        Fastlane::SHELLS.each do |shell_name|
          open("#{fastlane_conf_dir}/completions/completion.#{shell_name}", 'a') do |file|
            default_line_prefix = Helper.bundler? ? "bundle exec " : ""

            file.puts(self.get_auto_complete_line(shell_name, "#{default_line_prefix}fastlane"))

            custom_commands.each do |command|
              auto_complete_line = self.get_auto_complete_line(shell_name, command)

              next if auto_complete_line.nil?

              file.puts(auto_complete_line)
            end
          end
        end

        UI.success("Copied! To use auto complete for fastlane, add the following line to your favorite rc file (e.g. ~/.bashrc)")
        UI.important("  . ~/.fastlane/completions/completion.sh")
        UI.success("Don't forget to source that file in your current shell! 🐚")
      end
    end

    # Helper to get the auto complete register script line
    def self.get_auto_complete_line(shell, command)
      if shell == :bash
        prefix = "complete -F"
      elsif shell == :zsh
        prefix = "compctl -K"
      else
        return nil
      end

      return "#{prefix} _fastlane_complete #{command}"
    end
  end
end
