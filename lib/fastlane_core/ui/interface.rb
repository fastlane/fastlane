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
    def error(message)
      not_implemented(__method__)
    end

    # Level Warning: Can be used to show warnings to the user
    #   not necessarly negative, but something the user should 
    #   be aware of.
    # 
    #   By default those messages are shown in yellow
    def warn(message)
      not_implemented(__method__)
    end

    # Level Success: Show that something was successful
    # 
    #   By default those messages are shown in green
    def success(message)
      not_implemented(__method__)
    end

    # Level Message: Show a neutral message to the user
    # 
    #   By default those messages shown in white/black
    def message(message)
      not_implemented(__method__)
    end

    # Level Command: Print out a terminal command that is being 
    #   executed. 
    # 
    #   By default those messages shown in cyan
    def command(message)
      not_implemented(__method__)
    end

    # Level Verbose: Print out additional information for the
    #   users that are interested. Will only be printed when
    #   $verbose = true
    # 
    #   By default those messages are shown in white
    def verbose(message)
      not_implemented(__method__)
    end

    #####################################################
    # @!group Errors: Different kinds of exceptions
    #####################################################

    # Pass an exception to this method to exit the program 
    #   using the given exception
    def crash(exception)
      not_implemented(__method__)
    end

    # Use this method to exit the program because of an user error
    #   e.g. app doesn't exist on the given Developer Account
    #        or invalid user credentials
    # This will show the error message, but doesn't show the full
    #   stack trace
    def user_error(error_message)
      not_implemented(__method__)
    end

    #####################################################
    # @!group Helpers
    #####################################################
    def not_implemented(method_name)
      raise "Current UI '#{self}' doesn't support method '#{method_name}'".red
    end

    def to_s
      self.class.name.split('::').last
    end
  end
end
