module Spaceship
  module Tunes
    # Represents a version set inside of an application
    class VersionSet < TunesBase
      #####################################################
      # @!group General metadata
      #####################################################

      # @return (String) The type of the version set. So far only APP
      attr_accessor :type

      # @return (Spaceship::Tunes::Application) A reference to the application the version_set is contained in
      attr_accessor :application

      # @return (String)
      attr_accessor :platform

      attr_mapping(
        'type' => :type,
        'platformString' => :platform
      )

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end
      end
    end
  end
end

#
#
