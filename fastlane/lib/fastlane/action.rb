require 'fastlane/actions/actions_helper'

module Fastlane
  class Action
    def self.run(params)
    end

    # Implement in subclasses
    def self.description
      "No description provided".red
    end

    def self.details
      nil # this is your change to provide a more detailed description of this action
    end

    def self.available_options
      # [
      #   FastlaneCore::ConfigItem.new(key: :ipa_path,
      #                                env_name: "CRASHLYTICS_IPA_PATH",
      #                                description: "Value Description")
      # ]
      nil
    end

    def self.output
      # Return the keys you provide on the shared area
      # [
      #   ['IPA_OUTPUT_PATH', 'The path to the newly generated ipa file']
      # ]
      nil
    end

    def self.return_value
      # Describes what this method returns
      nil
    end

    def self.author
      nil
    end

    def self.authors
      nil
    end

    def self.is_supported?(platform)
      # you can do things like
      #  true
      #
      #  platform == :ios
      #
      #  [:ios, :mac].include?(platform)
      #
      UI.crash!("Implementing `is_supported?` for all actions is mandatory. Please update #{self}")
    end

    # Is printed out in the Steps: output in the terminal
    # Return nil if you don't want any logging in the terminal/JUnit Report
    def self.step_text
      self.action_name
    end

    # to allow a simple `sh` in the custom actions
    def self.sh(command)
      Fastlane::Actions.sh(command)
    end

    # instead of "AddGitAction", this will return "add_git" to print it to the user
    def self.action_name
      self.name.split('::').last.gsub('Action', '').fastlane_underscore
    end
  end
end
