require "fastlane/actions/actions_helper"

module Fastlane
  class Action
    def self.run(_params)
    end

    # Implement in subclasses
    def self.description
      "No description provided".red
    end

    def self.details
      nil # this is your change to provide a more detailed description of this action
    end

    def self.available_options
      # Return an array of 2-3 element arrays, like:
      # [
      #   ['app_identifier', 'This value is responsible for X', 'ENVIRONMENT_VARIABLE'],
      #   ['app_identifier', 'This value is responsible for X']
      # ]
      # Take a look at sigh.rb if you're using the config manager of fastlane
      nil
    end

    def self.output
      # Return the keys you provide on the shared area
      # [
      #   ['IPA_OUTPUT_PATH', 'The path to the newly generated ipa file']
      # ]
      nil
    end

    def self.author
      "KrauseFx"
    end

    def self.is_supported?(_platform)
      # you do things like
      #  true
      #
      #  platform == :ios
      #
      #  [:ios, :android].include?platform
      #
      fail "Implementing `is_supported?` for all actions is mandatory. Please update #{self}".red
    end

    # to allow a simple `sh` in the custom actions
    def self.sh(command)
      Fastlane::Actions.sh(command)
    end

    # instead of "AddGitAction", this will return "add_git" to print it to the user
    def self.action_name
      name.split("::").last.gsub("Action", "").fastlane_underscore
    end
  end
end
