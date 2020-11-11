module Fastlane
  module Actions
    class UploadAppDataUsageToAppStoreAction < Action
      DEFAULT_PATH = Fastlane::Helper.fastlane_enabled_folder_path
      DEFAULT_FILE_NAME = "app_data_usages.json"

      def self.run(params)
        require 'spaceship'

        # Team selection passed though FASTLANE_ITC_TEAM_ID and FASTLANE_ITC_TEAM_NAME environment variables
        # Prompts select team if multiple teams and none specified
        UI.message("Login to App Store Connect (#{params[:username]})")
        Spaceship::ConnectAPI.login(params[:username], use_portal: false, use_tunes: true)
        UI.message("Login successful")

        # Get App
        app = Spaceship::ConnectAPI::App.find(params[:app_identifier])
        unless app
          UI.user_error!("Could not find app with bundle identifier '#{params[:app_identifier]}' on account #{params[:username]}")
        end
        puts("found app")

        # Attempt too load JSON file
        usages_config = load_json_file(params)

        # Start interactive questions to generate and save JSON file
        unless usages_config
          usages_config = ask_interactive_questions_for_json

          json = JSON.pretty_generate(usages_config)
          path = output_path(params)

          UI.message("Writing file to #{path}")
          File.write(path, json)
        end

        # Process JSON file to save app data usages to API
        upload_app_data_usages(params, app, usages_config)
      end

      def self.load_json_file(params)
        path = params[:json_path]
        return nil if path.nil?
        return nil unless File.exist?(path)
        return JSON.parse(File.read(path))
      end

      def self.output_path(params)
        path = params[:output_json_path] || DEFAULT_PATH
        path = File.absolute_path(path)
        return File.join(path, DEFAULT_FILE_NAME)
      end

      def self.ask_interactive_questions_for_json
        UI.important("You did not provide a JSON file for updating the app data usages")
        UI.important("fastlane will now run you through interactive question to generate the JSON file")
        UI.important("")
        UI.important("This JSON file can be saved in source control and used in this action with the :json_file option")

        unless UI.confirm("Ready to start?")
          UI.user_error!("Cancelled")
        end

        categories = Spaceship::ConnectAPI::AppDataUsageCategory.all(includes: "grouping")
        purposes = Spaceship::ConnectAPI::AppDataUsagePurpose.all

        json = []

        unless UI.confirm("Are you collecting data?")
          json << {
            "data_protections" => ["DATA_NOT_COLLECTED"]
          }

          return json
        end

        categories.each do |category|
          next unless UI.confirm("Collect data for #{category.id}?")

          purpose_names = purposes.map(&:id).join(', ')
          UI.message("How will this data be used? You'll be offered with #{purpose_names}")

          selected_purposes = []
          purposes.each do |purpose|
            selected_purposes << purpose if UI.confirm("Used for #{purpose.id}?")
          end

          is_linked_to_user = UI.confirm("Is #{category.id} linked to the user?")
          is_used_for_tracking = UI.confirm("Is #{category.id} used for tracking purposes?")

          protection_id = is_linked_to_user ? "DATA_LINKED_TO_YOU" : "DATA_NOT_LINKED_TO_YOU"
          tracking_id = is_used_for_tracking ? "DATA_USED_TO_TRACK_YOU" : nil

          json << {
            "category" => category.id,
            "purposes" => selected_purposes.map(&:id),
            "data_protections" => [
              protection_id, tracking_id
            ].compact
          }
        end

        return json
      end

      def self.upload_app_data_usages(params, app, usages_config)
        puts("before usages")
        all_usages = Spaceship::ConnectAPI::AppDataUsage.all(app_id: app.id, includes: "category,grouping,purpose,dataProtection", limit: 500)
        puts("all usages - #{all_usages.size}")
        all_usages.each do |usage|
          puts("about to delete")
          usage.delete!
        end

        puts("trying to loop")
        usages_config.each do |usage_config|
          category = usage_config[:category]
          purposes = usage_config[:purposes] || []
          data_protections = usage_config[:data_protections] || []

          purposes = [nil] if purposes.empty?

          purposes.each do |purpose|
            data_protections.each do |data_protection|
              UI.message("Setting #{category} and #{purpose} to #{data_protection}")
              Spaceship::ConnectAPI::AppDataUsage.create(
                app_id: app.id,
                app_data_usage_category_id: category,
                app_data_usage_protection_id: data_protection,
                app_data_usage_purpose_id: purpose
              )
            end
          end
        end

        puts("about to publish")

        # Publish
        publish_state = Spaceship::ConnectAPI::AppDataUsagesPublishState.get(app_id: app.id)
        if publish_state.published
          UI.important("App data usage is already published")
        else
          UI.important("App data usage not published!")
          if UI.confirm("Do you want to publish these app data usages?")
            publish_state.publish!
          end
        end
      end

      def self.ask_interactive_questions(app)
        categories = Spaceship::ConnectAPI::AppDataUsageCategory.all(includes: "grouping")
        purposes = Spaceship::ConnectAPI::AppDataUsagePurpose.all
        all_usages = Spaceship::ConnectAPI::AppDataUsage.all(app_id: app.id, includes: "category,grouping,purpose,dataProtection", limit: 500)

        not_collected_usage = all_usages.find(&:is_not_collected?)

        usages = all_usages.reject(&:is_not_collected?).sort do |a, b|
          a.category.id <=> b.category.id
        end

        usage_categories = usages.map { |u| u.category.id }

        if not_collected_usage
          UI.important("Not collecting any data")
        elsif !usage_categories.empty?
          UI.important("Currently using categories: #{usage_categories.uniq.join(', ')}")
        end

        if not_collected_usage.nil?
          if UI.confirm("Turn off data collection?")
            usages.each(&:delete!)

            Spaceship::ConnectAPI::AppDataUsage.create(app_id: app.id, app_data_usage_protection_id: "DATA_NOT_COLLECTED")

            return
          end
        end

        if UI.confirm("Add collection categories?")
          not_collected_usage.delete! if not_collected_usage

          categories.each do |category|
            next if usage_categories.include?(category.id)

            next unless UI.confirm("Collect data for #{category.id}?")

            purpose_names = purposes.map(&:id).join(', ')
            UI.message("How will this data be used? You'll be offered with #{purpose_names}")

            selected_purposes = []
            purposes.each do |purpose|
              selected_purposes << purpose if UI.confirm("Used for #{purpose.id}?")
            end

            is_linked_to_user = UI.confirm("Is #{category.id} linked to the user?")
            is_used_for_tracking = UI.confirm("Is #{category.id} used for tracking purposes?")

            protection_id = is_linked_to_user ? "DATA_LINKED_TO_YOU" : "DATA_NOT_LINKED_TO_YOU"

            selected_purposes.each do |purpose|
              Spaceship::ConnectAPI::AppDataUsage.create(
                app_id: app.id,
                app_data_usage_category_id: category.id,
                app_data_usage_protection_id: protection_id,
                app_data_usage_purpose_id: purpose.id
              )

              next unless is_used_for_tracking
              Spaceship::ConnectAPI::AppDataUsage.create(
                app_id: app.id,
                app_data_usage_category_id: category.id,
                app_data_usage_protection_id: "DATA_USED_TO_TRACK_YOU",
                app_data_usage_purpose_id: purpose.id
              )
            end
          end
        end

        publish_state = Spaceship::ConnectAPI::AppDataUsagesPublishState.get(app_id: app.id)
        if publish_state.published
          UI.important("App data usage is already published")
        else
          UI.important("App data usage not published!")
          if UI.confirm("Do you want to publish these app data usages?")
            publish_state.publish!
          end
        end
      end

      def self.description
        "Update App Data Usages for an app in App Store Connect"
      end

      def self.available_options
        user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "APP_STORE_APP_DATA_USAGES_USERNAME",
                                       description: "Your Apple ID Username for App Store Connect",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       short_option: "-a",
                                       env_name: "APP_STORE_APP_DATA_USAGES_APP_IDENTIFIER",
                                       description: "The bundle identifier of your app",
                                       optional: false,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-k",
                                       env_name: "APP_STORE_APP_DATA_USAGES_TEAM_ID",
                                       description: "The ID of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       is_string: false, # as we also allow integers, which we convert to strings anyway
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-e",
                                       env_name: "APP_STORE_APP_DATA_USAGES_TEAM_NAME",
                                       description: "The name of your App Store Connect team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                       end),

          FastlaneCore::ConfigItem.new(key: :json_path,
                                       short_option: "-g",
                                       env_name: "APP_STORE_APP_DATA_USAGES_JSON_PATH",
                                       description: "Path to the app usage data JSON path",
                                       is_string: true,
                                       optional: true,
                                       verify_block: proc do |value|
                                         UI.user_error!("Could not find JSON file at path '#{File.expand_path(value)}'") unless File.exist?(value)
                                         UI.user_error!("'#{value}' doesn't seem to be a JSON file") unless FastlaneCore::Helper.json_file?(File.expand_path(value))
                                       end),

          FastlaneCore::ConfigItem.new(key: :output_json_path,
                                       short_option: "-o",
                                       env_name: "APP_STORE_APP_DATA_USAGES_OUTPUT_JSON_PATH",
                                       description: "Path to the app usage data JSON path generated by interactive questions",
                                       is_string: true,
                                       optional: true)
        ]
      end

      def self.author
        "joshdholtz"
      end

      def self.is_supported?(platform)
        [:ios, :mac, :tvos].include?(platform)
      end

      def self.details
        "Update App Data Usages for an app in App Store Connect"
      end

      def self.example_code
        [
          # 'chatwork(
          #   message: "App successfully released!",
          #   roomid: 12345,
          #   success: true,
          #   api_token: "Your Token"
          # )'
        ]
      end

      def self.category
        :production
      end
    end
  end
end
