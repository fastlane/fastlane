require_relative 'tunes_base'

module Spaceship
  module Tunes
    # Represents a read only version of an App Store Connect Versions State History
    class AppVersionStatesHistory < TunesBase
      # @return (String) the state
      attr_reader :state_key

      # @return (String) The name of the user who made the change
      attr_reader :user_name

      # @return (String) the email of the user or nil
      attr_reader :user_email

      # @return (Integer) the date of the state
      attr_reader :date

      attr_mapping({
        'stateKey' => :state_key,
        'userName' => :user_name,
        'userEmail' => :user_email,
        'date' => :date
      })
    end
  end
end
