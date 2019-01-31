module Spaceship
  # Base class for errors that want to present their message as
  # preferred error info for fastlane error handling. See:
  # fastlane_core/lib/fastlane_core/ui/fastlane_runner.rb
  class BasicPreferredInfoError < StandardError
    TITLE = 'The request could not be completed because:'.freeze

    def preferred_error_info
      message ? [TITLE, message] : nil
    end
  end

  # Invalid user credentials were provided
  class InvalidUserCredentialsError < BasicPreferredInfoError; end

  # Raised when no user credentials were passed at all
  class NoUserCredentialsError < BasicPreferredInfoError; end

  class ProgramLicenseAgreementUpdated < BasicPreferredInfoError
    def show_github_issues
      false
    end
  end

  class AppleIDAndPrivacyAcknowledgementNeeded < BasicPreferredInfoError
    def show_github_issues
      false
    end
  end

  # User doesn't have enough permission for given action
  class InsufficientPermissions < BasicPreferredInfoError
    TITLE = 'Insufficient permissions for your Apple ID:'.freeze

    def preferred_error_info
      message ? [TITLE, message] : nil
    end

    # We don't want to show similar GitHub issues, as the error message
    # should be pretty clear
    def show_github_issues
      false
    end
  end

  class UnexpectedResponse < StandardError
    attr_reader :error_info

    def initialize(error_info = nil)
      super(error_info)
      @error_info = error_info
    end

    def preferred_error_info
      return nil unless @error_info.kind_of?(Hash) && @error_info['resultString']

      [
        "Apple provided the following error info:",
        @error_info['resultString'],
        @error_info['userString']
      ].compact.uniq # sometimes 'resultString' and 'userString' are the same value
    end
  end

  # Raised when 302 is received from portal request
  class AppleTimeoutError < BasicPreferredInfoError; end

  # Raised when 401 is received from portal request
  class UnauthorizedAccessError < BasicPreferredInfoError; end

  # Raised when 500 is received from App Store Connect
  class InternalServerError < BasicPreferredInfoError; end

  # Raised when 502 is received from App Store Connect
  class BadGatewayError < BasicPreferredInfoError; end

  # Raised when 504 is received from App Store Connect
  class GatewayTimeoutError < BasicPreferredInfoError; end
end
