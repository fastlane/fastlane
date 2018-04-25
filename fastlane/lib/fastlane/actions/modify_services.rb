module Fastlane
  module Actions
    class ModifyServicesAction < Action
      def self.run(params)
        require 'produce'

        return if Helper.test?

        Produce.config = params

        Dir.chdir(FastlaneCore::FastlaneFolder.path || Dir.pwd) do
          require 'produce/service'
          services = params[:services]

          enabled_services = services.reject { |k, v| v == 'off' }
          disabled_services = services.select { |k, v| v == 'off' }

          enabled_services_object = self.service_object
          enabled_services.each do |k, v|
            enabled_services_object.__hash__[k] = true
            enabled_services_object.send("#{k}=", v)
          end
          Produce::Service.enable(enabled_services_object, nil) unless enabled_services.empty?

          disabled_services_object = self.service_object
          disabled_services.each do |k, v|
            disabled_services_object.__hash__[k] = true
            disabled_services_object.send("#{k}=", v)
          end
          Produce::Service.disable(disabled_services_object, nil) unless disabled_services.empty?
        end
      end

      def self.service_object
        service_object = Object.new
        service_object.class.module_eval { attr_accessor :__hash__ }
        service_object.__hash__ = {}
        Produce::DeveloperCenter::ALLOWED_SERVICES.keys.each do |service|
          name = self.services_mapping[service]
          service_object.class.module_eval { attr_accessor :"#{name}" }
        end
        service_object
      end

      def self.services_mapping
        {
            app_group: 'app_group',
            apple_pay: 'apple_pay',
            associated_domains: 'associated_domains',
            data_protection: 'data_protection',
            game_center: 'game_center',
            health_kit: 'healthkit',
            home_kit: 'homekit',
            wireless_accessory: 'wireless_conf',
            icloud: 'icloud',
            in_app_purchase: 'in_app_purchase',
            inter_app_audio: 'inter_app_audio',
            passbook: 'passbook',
            push_notification: 'push_notification',
            siri_kit: 'sirikit',
            vpn_configuration: 'vpn_conf',
            network_extension: 'network_extension',
            hotspot: 'hotspot',
            multipath: 'multipath',
            nfc_tag_reading: 'nfc_tag_reading'
        }
      end

      def self.allowed_services_description
        return Produce::DeveloperCenter::ALLOWED_SERVICES.map do |k, v|
          "#{k}: (#{v.join('|')})"
        end.join(", ")
      end

      def self.description
        'Modifies the services of the app created on Developer Portal'
      end

      def self.details
        [
          "The options are the same as `:enable_services` in the [produce action](https://docs.fastlane.tools/actions/produce/#parameters_1)"
        ].join("\n")
      end

      def self.available_options
        require 'produce'
        user = CredentialsManager::AppfileConfig.try_fetch_value(:apple_dev_portal_id)
        user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)
        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       short_option: "-u",
                                       env_name: "PRODUCE_USERNAME",
                                       description: "Your Apple ID Username",
                                       default_value: user,
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: "PRODUCE_APP_IDENTIFIER",
                                       short_option: "-a",
                                       description: "App Identifier (Bundle ID, e.g. com.krausefx.app)",
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier),
                                       default_value_dynamic: true),
          FastlaneCore::ConfigItem.new(key: :services,
                                       display_in_shell: false,
                                       env_name: "PRODUCE_ENABLE_SERVICES",
                                       description: "Array with Spaceship App Services (e.g. #{allowed_services_description})",
                                       is_string: false,
                                       type: Hash,
                                       default_value: {},
                                       verify_block: proc do |value|
                                         allowed_keys = Produce::DeveloperCenter::ALLOWED_SERVICES.keys
                                         UI.user_error!("enable_services has to be of type Hash") unless value.kind_of?(Hash)
                                         value.each do |key, v|
                                           UI.user_error!("The key: '#{key}' is not supported in `enable_services' - following keys are available: [#{allowed_keys.join(',')}]") unless allowed_keys.include?(key.to_sym)
                                         end
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_id,
                                       short_option: "-b",
                                       env_name: "PRODUCE_TEAM_ID",
                                       description: "The ID of your Developer Portal team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_id),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_TEAM_ID"] = value.to_s
                                       end),
          FastlaneCore::ConfigItem.new(key: :team_name,
                                       short_option: "-l",
                                       env_name: "PRODUCE_TEAM_NAME",
                                       description: "The name of your Developer Portal team if you're in multiple teams",
                                       optional: true,
                                       code_gen_sensitive: true,
                                       default_value: CredentialsManager::AppfileConfig.try_fetch_value(:team_name),
                                       default_value_dynamic: true,
                                       verify_block: proc do |value|
                                         ENV["FASTLANE_TEAM_NAME"] = value.to_s
                                       end)
        ]
      end

      def self.author
        "bhimsenpadalkar"
      end

      def self.is_supported?(platform)
        platform == :ios
      end

      def self.example_code
        [
          'modify_services(
            username: "test.account@gmail.com",
            app_identifier: "com.someorg.app",
            services: {
              push_notifications: "on",
              associated_domains: "off"
            }
          )'
        ]
      end

      def self.category
        :misc
      end
    end
  end
end
