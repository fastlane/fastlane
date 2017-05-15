module Fastlane
  module Actions
    module SharedValues
    end

    class SetWhatsNewAction < Action
      def self.run(params)
        require 'spaceship'

        credentials = CredentialsManager::AccountManager.new(user: params[:username])
        Spaceship::Tunes.login(credentials.user, credentials.password)
        Spaceship::Tunes.select_team
        app = Spaceship::Tunes::Application.find(params[:app_identifier])

        start = Time.now
        build = wait_for_build(start, app)
        build.update_build_information!(whats_new: params[:whats_new])

        UI.success "What's new was set!"
      end

      def self.wait_for_build(start_time, app)
        loop do
          begin
            build = app.builds.sort_by(:upload_date).last
            return build if build.id != 0

            seconds_elapsed = (Time.now - start_time).to_i.abs
            case seconds_elapsed
            when 0..59
              time_elapsed = Time.at(seconds_elapsed).utc.strftime "%S seconds"
            when 60..3599
              time_elapsed = Time.at(seconds_elapsed).utc.strftime "%M:%S minutes"
            else
              time_elapsed = Time.at(seconds_elapsed).utc.strftime "%H:%M:%S hours"
            end

            UI.message "Waiting #{time_elapsed} for iTunes Connect to process the build #{build.train_version} (#{build.build_version})... this might take a while..."
          rescue => ex
            UI.error ex
            UI.error "Something failed... trying again to recover"
          end
          sleep 30
        end
        nil
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Waits for the build to finish initial processing and sets the What's New."
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "FASTLANE_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "ITUNESCONNECT_USER",
                                       description: "Your Apple ID Username",
                                       default_value: user),
          FastlaneCore::ConfigItem.new(key: :whats_new,
                                       short_option: "-w",
                                       env_name: "WHATS_NEW",
                                       description: "What's new text")
        ]
      end

      def self.output
        []
      end

      def self.authors
        ["carlosefonseca"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end
