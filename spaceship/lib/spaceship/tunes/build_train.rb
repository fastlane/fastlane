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

      # @return (String) The version number of this train
      attr_reader :version_string

      # @return (String) Platform (e.g. "ios")
      attr_reader :platform

      # @return (Bool) Is external beta testing enabled for this train? Only one train can have enabled testing.
      attr_reader :external_testing_enabled

      # @return (Bool) Is internal beta testing enabled for this train? Only one train can have enabled testing.
      attr_reader :internal_testing_enabled

      # @return (Array) An array of all builds that are inside this train (Spaceship::Tunes::Build)
      #  I never got this to work to properly try and debug this
      attr_reader :processing_builds

      attr_mapping(
        'versionString' => :version_string,
        'platform' => :platform,
        'externalTesting.value' => :external_testing_enabled,
        'internalTesting.value' => :internal_testing_enabled
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
          trains = []
          trains += client.build_trains(app_id, 'internal')['trains']
          trains += client.build_trains(app_id, 'external')['trains']

          result = {}
          trains.each do |attrs|
            attrs[:application] = application
            current = self.factory(attrs)
            result[current.version_string] = current
          end
          result
        end
      end

      # Setup all the builds and processing builds
      def setup
        super

        @builds = (self.raw_data['builds'] || []).collect do |attrs|
          attrs[:build_train] = self
          Tunes::Build.factory(attrs)
        end

        @processing_builds = (self.raw_data['buildsInProcessing'] || []).collect do |attrs|
          attrs[:build_train] = self
          Tunes::Build.factory(attrs)
        end

        # since buildsInProcessing appears empty, fallback to also including processing state from @builds
        @builds.each do |build|
          @processing_builds << build if build.processing == true && build.valid == true
        end
      end

      # @return (Spaceship::Tunes::Build) The latest build for this train, sorted by upload time.
      def latest_build
        @builds.max_by(&:upload_date)
      end

      # @param (testing_type) internal or external
      def update_testing_status!(new_value, testing_type, build = nil)
        data = client.build_trains(self.application.apple_id, testing_type)

        build ||= latest_build if testing_type == 'external'
        testing_key = "#{testing_type}Testing"

        # Delete the irrelevant trains and update the relevant one to enable testing
        data['trains'].delete_if do |train|
          if train['versionString'] != version_string
            true
          else
            train[testing_key]['value'] = new_value

            # also update the builds
            train['builds'].delete_if do |b|
              return true if b[testing_key].nil?

              if build && b["buildVersion"] == build.build_version
                b[testing_key]['value'] = new_value
                false
              elsif b[testing_key]['value'] == true
                b[testing_key]['value'] = false
                false
              else
                true
              end
            end

            false
          end
        end

        result = client.update_build_trains!(application.apple_id, testing_type, data)
        self.internal_testing_enabled = new_value if testing_type == 'internal'
        self.external_testing_enabled = new_value if testing_type == 'external'

        result
      end
    end
  end
end
