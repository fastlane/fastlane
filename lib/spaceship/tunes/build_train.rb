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
            attrs.merge!(application: application)
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
          attrs.merge!(build_train: self)
          Tunes::Build.factory(attrs)
        end

        @processing_builds = (self.raw_data['buildsInProcessing'] || []).collect do |attrs|
          attrs.merge!(build_train: self)
          Tunes::Build.factory(attrs)
        end
      end

      # @return (Spaceship::Tunes::Build) The latest build for this train, sorted by upload time.
      def latest_build
        @builds.max_by do |build|
          build.train_version == version_string && build.upload_date
        end
      end

      # @param (testing_type) internal or external
      def update_testing_status!(new_value, testing_type, build = nil)
        data = client.build_trains(self.application.apple_id, testing_type)

        build ||= latest_build if testing_type == 'external'

        data['trains'].each do |train|
          train["#{testing_type}Testing"]['value'] = false
          train["#{testing_type}Testing"]['value'] = new_value if train['versionString'] == version_string

          # also update the builds
          train['builds'].each do |b|
            next if b["#{testing_type}Testing"].nil?
            next if build.nil?
            next if b["buildVersion"] != build.build_version
            b["#{testing_type}Testing"]['value'] = false
            b["#{testing_type}Testing"]['value'] = new_value if b['trainVersion'] == version_string
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
