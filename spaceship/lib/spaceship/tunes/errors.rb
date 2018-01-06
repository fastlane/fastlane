require_relative '../errors'

module Spaceship
  module Tunes
    # ITunesConnectError is only thrown when iTunes Connect raises an exception
    class Error < BasicPreferredInfoError
    end

    # raised if the server failed to save temporarily
    class TemporaryError < Spaceship::Tunes::Error
    end

    # raised if the server failed to save, and it might be caused by an invisible server error
    class PotentialServerError < Spaceship::Tunes::Error
    end
  end
end
