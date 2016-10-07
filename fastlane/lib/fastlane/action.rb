require 'fastlane/actions/actions_helper'

module Fastlane
  class Action
    AVAILABLE_CATEGORIES = [
      :testing,
      :building,
      :screenshots,
      :project,
      :code_signing,
      :documentation,
      :beta,
      :push,
      :production,
      :source_control,
      :notifications,
      :deprecated,
      :misc
    ]

    class << self
      attr_accessor :runner
    end

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

    def self.sample_return_value
      # Very optional
      # You can return a sample return value, that might be returned by the actual action
      # This is currently only used when generating the documentation and running its tests
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

    # Returns an array of string of sample usage of this action
    def self.example_code
      nil
    end

    # Is printed out in the Steps: output in the terminal
    # Return nil if you don't want any logging in the terminal/JUnit Report
    def self.step_text
      self.action_name
    end

    # to allow a simple `sh` in the custom actions
    def self.sh(command, print_command: true, print_command_output: true, error_callback: nil)
      Fastlane::Actions.sh_control_output(command, print_command: print_command, print_command_output: print_command_output, error_callback: error_callback)
    end

    # Documentation category, availabe values defined in AVAILABLE_CATEGORIES
    def self.category
      :undefined
    end

    # instead of "AddGitAction", this will return "add_git" to print it to the user
    def self.action_name
      self.name.split('::').last.gsub('Action', '').fastlane_underscore
    end

    def self.lane_context
      Actions.lane_context
    end

    # Allows the user to call an action from an action
    def self.method_missing(method_sym, *arguments, &_block)
      UI.error("Unknown method '#{method_sym}'")
      UI.user_error!("To call another action from an action use `OtherAction.#{method_sym}` instead")
    end

    # Return a new instance of the OtherAction action
    # We need to do this, since it has to have access to
    # the runner object
    def self.other_action
      return OtherAction.new(self.runner)
    end
  end
end
