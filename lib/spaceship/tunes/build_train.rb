module Spaceship
  module Tunes
    # Represents a build train of builds from iTunes Connect
    # A build train is all builds for a given version number with different build numbers
    class BuildTrain < TunesBase

      # @return (Spaceship::Tunes::Application) A reference to the application
      #   this train is for
      attr_accessor :application

      # @return (Array) An array of all builds that are inside this train (Spaceship::Tunes::Build)
      attr_reader :builds

      # @return (Array) An array of all builds that are inside this train (Spaceship::Tunes::Build)
      attr_reader :processing_builds

      # @return (String) The version number of this train
      attr_accessor :version_string

      # @return (String) Platform (e.g. "ios")
      attr_accessor :platform

      # @return (Bool) Is beta testing enabled for this train? Only one train can have enabled testing.
      attr_accessor :testflight_testing_enabled



      attr_mapping(
        'versionString' => :version_string,
        'platform' => :platform,
        'testing.value' => :testflight_testing_enabled
      )

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @param application (Spaceship::Tunes::Application) The app this train is for
        # @param app_id (String) The unique Apple ID of this app
        def all(application, app_id)
          data = client.build_trains(app_id)
          result = data['trains'].collect do |attrs|
            attrs.merge!(application: application)
            self.factory(attrs)
          end
        end
      end

      # Setup all the builds and processing builds
      def setup
        @builds = self.raw_data['builds'].collect do |attrs|
          attrs.merge!(build_train: self)
          Tunes::Build.factory(attrs)
        end
      end
    end
  end
end