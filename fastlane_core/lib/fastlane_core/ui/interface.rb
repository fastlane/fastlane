module FastlaneCore
  # Abstract super class
  class Interface
    #####################################################
    # @!group Messaging: show text to the user
    #####################################################

    # Level Error: Can be used to show additional error
    #   information before actually raising an exception
    #   or can be used to just show an error from which
    #   fastlane can recover (much magic)
    #
    #   By default those messages are shown in red
    def error(_message)
      not_implemented(__method__)
    end

    # Level Important: Can be used to show warnings to the user
    #   not necessarily negative, but something the user should
    #   be aware of.
    #
    #   By default those messages are shown in yellow
    def important(_message)
      not_implemented(__method__)
    end

    # Level Success: Show that something was successful
    #
    #   By default those messages are shown in green
    def success(_message)
      not_implemented(__method__)
    end

    # Level Message: Show a neutral message to the user
    #
    #   By default those messages shown in white/black
    def message(_message)
      not_implemented(__method__)
    end

    # Level Deprecated: Show that a particular function is deprecated
    #
    #   By default those messages shown in strong blue
    def deprecated(_message)
      not_implemented(__method__)
    end

    # Level Command: Print out a terminal command that is being
    #   executed.
    #
    #   By default those messages shown in cyan
    def command(_message)
      not_implemented(__method__)
    end

    # Level Command Output: Print the output of a command with
    #   this method
    #
    #   By default those messages shown in magenta
    def command_output(_message)
      not_implemented(__method__)
    end

    # Level Verbose: Print out additional information for the
    #   users that are interested. Will only be printed when
    #   FastlaneCore::Globals.verbose? = true
    #
    #   By default those messages are shown in white
    def verbose(_message)
      not_implemented(__method__)
    end

    # Print a header = a text in a box
    #   use this if this message is really important
    def header(_message)
      not_implemented(__method__)
    end

    #####################################################
    # @!group Errors: Inputs
    #####################################################

    # Is is possible to ask the user questions?
    def interactive?
      not_implemented(__method__)
    end

    # get a standard text input (single line)
    def input(_message)
      not_implemented(__method__)
    end

    # A simple yes or no question
    def confirm(_message)
      not_implemented(__method__)
    end

    # Let the user select one out of x items
    # return value is the value of the option the user chose
    def select(_message, _options)
      not_implemented(__method__)
    end

    # Password input for the user, text field shouldn't show
    # plain text
    def password(_message)
      not_implemented(__method__)
    end

    #####################################################
    # @!group Errors: Different kinds of exceptions
    #####################################################

    class FastlaneException < StandardError
      def prefix
        '[FASTLANE_EXCEPTION]'
      end

      def caused_by_calling_ui_method?(method_name: nil)
        return false if backtrace.nil? || backtrace[0].nil? || method_name.nil?
        first_frame = backtrace[0]
        if first_frame.include?(method_name) || first_frame.include?('interface.rb')
          true
        else
          false
        end
      end

      def trim_backtrace(method_name: nil)
        if caused_by_calling_ui_method?(method_name: method_name)
          backtrace.drop(2)
        else
          backtrace
        end
      end

      def could_contain_pii?
        caused_by_calling_ui_method?
      end
    end


    # raised from crash!
    class FastlaneCrash < FastlaneException
      def prefix
        '[FASTLANE_CRASH]'
      end

      def trimmed_backtrace
        trim_backtrace(method_name: 'crash!')
      end
    end

    # raised from user_error!
    class FastlaneError < FastlaneException
      attr_reader :show_github_issues
      attr_reader :error_info

      def initialize(show_github_issues: false, error_info: nil)
        @show_github_issues = show_github_issues
        @error_info = error_info
      end

      def prefix
        '[USER_ERROR]'
      end

      def trimmed_backtrace
        trim_backtrace(method_name: 'crash!')
      end
    end

    # raised from build_failure!
    class FastlaneBuildFailure < FastlaneError
    end

    # raised from test_failure!
    class FastlaneTestFailure < StandardError
    end

    # Pass an exception to this method to exit the program
    #   using the given exception
    # Use this method instead of user_error! if this error is
    # unexpected, e.g. an invalid server response that shouldn't happen
    def crash!(exception)
      raise FastlaneCrash.new, exception.to_s
    end

    # Use this method to exit the program because of an user error
    #   e.g. app doesn't exist on the given Developer Account
    #        or invalid user credentials
    #        or scan tests fail
    # This will show the error message, but doesn't show the full
    #   stack trace
    # Basically this should be used when you actively catch the error
    # and want to show a nice error message to the user
    def user_error!(error_message, options = {})
      raise FastlaneError.new(options), error_message.to_s
    end

    # Use this method to exit the program because of a build failure
    # that's caused by the source code of the user. Example for this
    # is that gym will fail when the code doesn't compile or because
    # settings for the project are incorrect.
    # By using this method we'll have more accurate results about
    # fastlane failures
    def build_failure!(error_message, options = {})
      raise FastlaneBuildFailure.new(options), error_message.to_s
    end

    # Use this method to exit the program because of a test failure
    # that's caused by the source code of the user. Example for this
    # is that scan will fail when the tests fail.
    # By using this method we'll have more accurate results about
    # fastlane failures
    def test_failure!(error_message)
      raise FastlaneTestFailure.new, error_message
    end

    #####################################################
    # @!group Helpers
    #####################################################
    def not_implemented(method_name)
      UI.user_error!("Current UI '#{self}' doesn't support method '#{method_name}'")
    end

    def to_s
      self.class.name.split('::').last
    end
  end
end

class String
  def deprecated
    self.bold.blue
  end
end
