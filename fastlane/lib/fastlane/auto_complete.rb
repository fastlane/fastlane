require 'fileutils'

module Fastlane
  # Enable tab auto completion
  class AutoComplete
    def self.execute
      shell = ENV['SHELL']

      if shell.end_with? "fish"
        fish_completions_dir = "~/.config/fish/completions"
        confirm = UI.confirm "This will copy a fish script into #{fish_completions_dir} that provides the command tab completion. If the directory does not exist it will be created. Sound good?"
        return unless confirm

        fish_completions_dir = File.expand_path fish_completions_dir
        FileUtils.mkdir_p fish_completions_dir

        completion_script_path = File.join(Fastlane::ROOT, 'lib', 'assets', 'completions', 'completion.fish')
        final_completion_script_path = File.join(fish_completions_dir, 'fastlane.fish')

        FileUtils.cp completion_script_path, final_completion_script_path

        UI.success "Copied! You can now use tab completion for lanes"
      else
        fastlane_conf_dir = "~/.fastlane"
        confirm = UI.confirm "This will copy a shell script into #{fastlane_conf_dir} that provides the command tab completion. Sound good?"
        return unless confirm

        # create the ~/.fastlane directory
        fastlane_conf_dir = File.expand_path fastlane_conf_dir
        FileUtils.mkdir_p fastlane_conf_dir

        # then copy all of the completions files into it from the gem
        completion_script_path = File.join(Fastlane::ROOT, 'lib', 'assets', 'completions')
        FileUtils.cp_r completion_script_path, fastlane_conf_dir

        UI.success "Copied! To use auto complete for fastlane, add the following line to your favorite rc file (e.g. ~/.bashrc)"
        UI.important "  . ~/.fastlane/completions/completion.sh"
        UI.success "Don't forget to source that file in your current shell! 🐚"
      end
    end
  end
end
