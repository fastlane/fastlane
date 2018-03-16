require_relative 'tunes_base'
require_relative 'errors'
require_relative 'build'

module Spaceship
  module Tunes
    # Represents a build train of builds from iTunes Connect
    # A build train is all builds for a given version number with different build numbers
    class BuildTrain < TunesBase
      # @return (Spaceship::Tunes::Application) A reference to the application this train is for
      attr_accessor :application

      # @return (Spaceship::Tunes::VersionSet) A reference to the version set
      #   this train is for
      attr_accessor :version_set

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

      # @return (Array) An array of all processing builds that are inside this train (Spaceship::Tunes::Build)
      # Does not include invalid builds.
      #  I never got this to work to properly try and debug this
      attr_reader :processing_builds

      # @return (Array) An array of all invalid builds that are inside this train
      attr_reader :invalid_builds

      attr_mapping(
        'application' => 'application',
        'versionString' => :version_string,
        'platform' => :platform,
        'externalTesting.value' => :external_testing_enabled,
        'internalTesting.value' => :internal_testing_enabled
      )

      class << self
        # @param application (Spaceship::Tunes::Application) The app this train is for
        # @param app_id (String) The unique Apple ID of this app
        def all(application, app_id, platform: nil)
          trains = []
          trains += client.build_trains(app_id, 'internal', platform: platform)['trains']
          trains += client.build_trains(app_id, 'external', platform: platform)['trains']

          result = {}
          trains.each do |attrs|
            attrs[:application] = application
            current = self.factory(attrs)
            if (!platform.nil? && current.platform == platform) || platform.nil?
              result[current.version_string] = current
            end
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

        @invalid_builds = @builds.select do |build|
          build.processing_state == 'processingFailed' || build.processing_state == 'invalidBinary'
        end

        # This step may not be necessary anymore - it seems as if every processing build will be caught by the
        # @builds.each below, but not every processing build makes it to buildsInProcessing, so this is redundant
        @processing_builds = (self.raw_data['buildsInProcessing'] || []).collect do |attrs|
          attrs[:build_train] = self
          Tunes::Build.factory(attrs)
        end

        # since buildsInProcessing appears empty, fallback to also including processing state from @builds
        @builds.each do |build|
          # What combination of attributes constitutes which state is pretty complicated. The table below summarizes
          # what I've observed, but there's no reason to believe there aren't more states I just haven't seen yet.
          # The column headers are qualitative states of a given build, and the first column is the observed attributes
          # of that build.
          # NOTE: Some of the builds in the build_trains.json fixture do not follow these rules. I don't know if that is
          # because those examples are older, and the iTC API has changed, or if their format is still a possibility.
          # The second part of the OR clause in the line below exists so that those suspicious examples continue to be
          # accepted for unit tests.
          # +---------------------+-------------------+-------------------+-----------------+--------------------+---------+
          # |                     | just after upload | normal processing | invalid binary  | processing failed  | success |
          # +---------------------+-------------------+-------------------+-----------------+--------------------+---------+
          # |  build.processing = | true              | true              | true            | true               | false   |
          # |       build.valid = | false             | true              | false           | true               | true    |
          # | .processing_state = | "processing"      | "processing"      | "invalidBinary" | "processingFailed" | nil     |
          # +---------------------+-------------------+-------------------+-----------------+--------------------+---------+
          if build.processing_state == 'processing' || (build.processing && build.processing_state != 'invalidBinary' && build.processing_state != 'processingFailed')
            @processing_builds << build
          end
        end

        self.version_set = self.application.version_set_for_platform(self.platform)
      end

      # @return (Spaceship::Tunes::Build) The latest build for this train, sorted by upload time.
      def latest_build
        @builds.max_by(&:upload_date)
      end

      # @param (testing_type) internal or external
      def update_testing_status!(new_value, testing_type, build = nil)
        build ||= latest_build if testing_type == 'external'
        platform = build ? build.platform : self.application.platform
        testing_key = "#{testing_type}Testing"

        data = client.build_trains(self.application.apple_id, testing_type, platform: platform)

        # Delete the irrelevant trains and update the relevant one to enable testing
        data['trains'].delete_if do |train|
          if train['versionString'] != version_string
            true
          else
            train[testing_key]['value'] = new_value

            # also update the builds
            train['builds'].delete_if do |b|
              if b[testing_key].nil?
                true
              elsif build && b["buildVersion"] == build.build_version
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

        begin
          result = client.update_build_trains!(application.apple_id, testing_type, data)
        rescue Spaceship::Tunes::Error => ex
          if ex.to_s.include?("You must provide an answer for this question")
            # This is a very common error message that's raised by TestFlight
            # We want to show a nicer error message with instructions on how
            # to resolve the underlying issue
            # https://github.com/fastlane/fastlane/issues/1873
            # https://github.com/fastlane/fastlane/issues/4002
            error_message = [""] # to have a nice new-line in the beginning
            error_message << "TestFlight requires you to provide the answer to the encryption question"
            error_message << "to provide the reply, please add the following to your Info.plist file"
            error_message << ""
            error_message << "<key>ITSAppUsesNonExemptEncryption</key><false/>"
            error_message << ""
            error_message << "Afterwards re-build your app and try again"
            error_message << "iTunes Connect reported: '#{ex}'"
            raise error_message.join("\n")
          else
            raise ex
          end
        end
        self.internal_testing_enabled = new_value if testing_type == 'internal'
        self.external_testing_enabled = new_value if testing_type == 'external'

        result
      end
    end
  end
end
