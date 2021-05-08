require_relative 'errors'

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

    # Print lines of content around specific line where
    #   failed to parse.
    #
    #   This message will be shown as error
    def content_error(content, error_line)
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
    # @!group Abort helper methods
    #####################################################

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
      raise FastlaneError.new(show_github_issues: options[:show_github_issues], error_info: options[:error_info]), error_message.to_s
    end

    # Use this method to exit the program because of a shell command
    # failure -- the command returned a non-zero response. This does
    # not specify the nature of the error. The error might be from a
    # programming error, a user error, or an expected  error because
    # the user of the Fastfile doesn't have their environment set up
    # properly. Because of this, when these errors occur, it means
    # that the caller of the shell command did not adequate error
    # handling and the caller error handling should be improved.
    def shell_error!(error_message, options = {})
      raise FastlaneShellError.new(options), error_message.to_s
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

    # Use this method to exit the program because of terminal state
    # that is neither the fault of fastlane, nor a problem with the
    # user's input. Using this method instead of user_error! will
    # avoid tracking this outcome as a fastlane failure.
    #
    #   e.g. tests ran successfully, but no screenshots were found
    #
    # This will show the message, but hide the full stack trace.
    def abort_with_message!(message)
      raise FastlaneCommonException.new, message
    end

    #####################################################
    # @!group Helpers
    #####################################################
    def not_implemented(method_name)
      require_relative 'ui'
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
