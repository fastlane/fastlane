require 'fastlane/actions/actions_helper'
require 'forwardable'

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
      :app_store_connect,
      :misc,
      :deprecated # This should be the last item
    ]

    RETURN_TYPES = [
      :string,
      :array_of_strings,
      :hash_of_strings,
      :hash,
      :bool,
      :int
    ]

    class << self
      attr_accessor :runner

      extend(Forwardable)

      # to allow a simple `sh` in the custom actions
      def_delegator(Actions, :sh_control_output, :sh)
    end

    def self.run(params)
    end

    # Implement in subclasses
    def self.description
      "No description provided".red
    end

    def self.details
      nil # this is your chance to provide a more detailed description of this action
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

    def self.return_type
      # Describes what type of data is expected to be returned, see RETURN_TYPES
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

    # Documentation category, available values defined in AVAILABLE_CATEGORIES
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
      UI.user_error!("To call another action from an action use `other_action.#{method_sym}` instead")
    end

    # When shelling out from the actoin, should we use `bundle exec`?
    def self.shell_out_should_use_bundle_exec?
      return File.exist?('Gemfile') && !Helper.contained_fastlane?
    end

    # Return a new instance of the OtherAction action
    # We need to do this, since it has to have access to
    # the runner object
    def self.other_action
      return OtherAction.new(self.runner)
    end

    # Describes how the user should handle deprecated an action if its deprecated
    # Returns a string (or nil)
    def self.deprecated_notes
      nil
    end
  end
end

class String
  def markdown_preserve_newlines
    self.gsub(/(\n|$)/, '|\1') # prepend new lines with "|" so the erb template knows *not* to replace them with "<br>"s
  end

  def markdown_sample(is_first = false)
    self.markdown_clean_heredoc!
    self.markdown_details(is_first)
  end

  def markdown_list(is_first = false)
    self.markdown_clean_heredoc!
    self.gsub!(/^/, "- ") # add list dashes
    self.prepend(">") unless is_first # the empty line that will be added breaks the quote
    self.markdown_details(is_first)
  end

  def markdown_details(is_first)
    self.prepend("\n") unless is_first
    self << "\n>" # continue the quote
    self.markdown_preserve_newlines
  end

  def markdown_clean_heredoc!
    self.chomp! # remove the last new line added by the heredoc
    self.dedent! # remove the leading whitespace (similar to the squigly heredoc `<<~`)
  end

  def dedent!
    first_line_indent = self.match(/^\s*/)[0]

    self.gsub!(/^#{first_line_indent}/, "")
  end
end
