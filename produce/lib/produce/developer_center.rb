require "spaceship"
require_relative "module"

module Produce
  class DeveloperCenter
    SERVICE_ON = "on"
    SERVICE_OFF = "off"
    SERVICE_COMPLETE = "complete"
    SERVICE_UNLESS_OPEN = "unlessopen"
    SERVICE_UNTIL_FIRST_LAUNCH = "untilfirstauth"
    SERVICE_LEGACY = "legacy"
    SERVICE_CLOUDKIT = "cloudkit"
    SERVICE_GAME_CENTER_IOS = "ios"
    SERVICE_GAME_CENTER_MAC = "mac"
    SERVICE_PRIMARY_APP_CONSENT = "on"

    ALLOWED_SERVICES = {
      access_wifi: [SERVICE_ON, SERVICE_OFF],
      app_attest: [SERVICE_ON, SERVICE_OFF],
      app_group: [SERVICE_ON, SERVICE_OFF],
      apple_pay: [SERVICE_ON, SERVICE_OFF],
      associated_domains: [SERVICE_ON, SERVICE_OFF],
      auto_fill_credential: [SERVICE_ON, SERVICE_OFF],
      class_kit: [SERVICE_ON, SERVICE_OFF],
      declared_age_range: [SERVICE_ON, SERVICE_OFF],
      icloud: [SERVICE_LEGACY, SERVICE_CLOUDKIT],
      custom_network_protocol: [SERVICE_ON, SERVICE_OFF],
      data_protection: [
        SERVICE_COMPLETE,
        SERVICE_UNLESS_OPEN,
        SERVICE_UNTIL_FIRST_LAUNCH
      ],
      family_controls: [SERVICE_ON, SERVICE_OFF],
      file_provider_testing_mode: [SERVICE_ON, SERVICE_OFF],
      fonts: [SERVICE_ON, SERVICE_OFF],
      game_center: [SERVICE_GAME_CENTER_IOS, SERVICE_GAME_CENTER_MAC],
      health_kit: [SERVICE_ON, SERVICE_OFF],
      hls_interstitial_preview: [SERVICE_ON, SERVICE_OFF],
      home_kit: [SERVICE_ON, SERVICE_OFF],
      hotspot: [SERVICE_ON, SERVICE_OFF],
      in_app_purchase: [SERVICE_ON, SERVICE_OFF],
      inter_app_audio: [SERVICE_ON, SERVICE_OFF],
      low_latency_hls: [SERVICE_ON, SERVICE_OFF],
      managed_associated_domains: [SERVICE_ON, SERVICE_OFF],
      maps: [SERVICE_ON, SERVICE_OFF],
      multipath: [SERVICE_ON, SERVICE_OFF],
      network_extension: [SERVICE_ON, SERVICE_OFF],
      nfc_tag_reading: [SERVICE_ON, SERVICE_OFF],
      personal_vpn: [SERVICE_ON, SERVICE_OFF],
      passbook: [SERVICE_ON, SERVICE_OFF],
      push_notification: [SERVICE_ON, SERVICE_OFF],
      sign_in_with_apple: [SERVICE_PRIMARY_APP_CONSENT],
      siri_kit: [SERVICE_ON, SERVICE_OFF],
      system_extension: [SERVICE_ON, SERVICE_OFF],
      user_management: [SERVICE_ON, SERVICE_OFF],
      vpn_configuration: [SERVICE_ON, SERVICE_OFF],
      wallet: [SERVICE_ON, SERVICE_OFF],
      wireless_accessory: [SERVICE_ON, SERVICE_OFF],
      car_play_audio_app: [SERVICE_ON, SERVICE_OFF],
      car_play_messaging_app: [SERVICE_ON, SERVICE_OFF],
      car_play_navigation_app: [SERVICE_ON, SERVICE_OFF],
      car_play_voip_calling_app: [SERVICE_ON, SERVICE_OFF],
      critical_alerts: [SERVICE_ON, SERVICE_OFF],
      hotspot_helper: [SERVICE_ON, SERVICE_OFF],
      driver_kit: [SERVICE_ON, SERVICE_OFF],
      driver_kit_endpoint_security: [SERVICE_ON, SERVICE_OFF],
      driver_kit_family_hid_device: [SERVICE_ON, SERVICE_OFF],
      driver_kit_family_networking: [SERVICE_ON, SERVICE_OFF],
      driver_kit_family_serial: [SERVICE_ON, SERVICE_OFF],
      driver_kit_hid_event_service: [SERVICE_ON, SERVICE_OFF],
      driver_kit_transport_hid: [SERVICE_ON, SERVICE_OFF],
      multitasking_camera_access: [SERVICE_ON, SERVICE_OFF],
      sf_universal_link_api: [SERVICE_ON, SERVICE_OFF],
      vp9_decoder: [SERVICE_ON, SERVICE_OFF],
      music_kit: [SERVICE_ON, SERVICE_OFF],
      shazam_kit: [SERVICE_ON, SERVICE_OFF],
      communication_notifications: [SERVICE_ON, SERVICE_OFF],
      group_activities: [SERVICE_ON, SERVICE_OFF],
      health_kit_estimate_recalibration: [SERVICE_ON, SERVICE_OFF],
      time_sensitive_notifications: [SERVICE_ON, SERVICE_OFF],
      extended_virtual_address_space: [SERVICE_ON, SERVICE_OFF],
      increased_memory_limit: [SERVICE_ON, SERVICE_OFF],
      increased_memory_limit_debugging: [SERVICE_ON, SERVICE_OFF],
    }

    # Keys supported by Spaceship::Portal::AppService (derived from AppService constants)
    PORTAL_APP_SERVICE_KEYS = Spaceship::Portal::AppService.constants.filter_map do |constant|
      next unless constant.to_s.match?(/\A[A-Z]/)

      constant.to_s
              .gsub(/([A-Z0-9]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z0-9])([A-Z])/, '\1_\2')
              .downcase
    end.freeze

    def run
      login
      create_new_app
      enable_connect_api_services
    end

    def create_new_app
      ENV["CREATED_NEW_APP_ID"] = Time.now.to_i.to_s
      if app_exists?
        UI.success("[DevCenter] App '#{Produce.config[:app_identifier]}' already exists, nothing to do on the Dev Center")
        ENV["CREATED_NEW_APP_ID"] = nil
        # Nothing to do here
      else
        app_name = Produce.config[:app_name]
        UI.message("Creating new app '#{app_name}' on the Apple Dev Center")

        app = Spaceship.app.create!(bundle_id: app_identifier,
                                    name: app_name,
                                    enable_services: enable_services,
                                    mac: platform == "osx")

        if app.name != Produce.config[:app_name]
          UI.important("Your app name includes non-ASCII characters, which are not supported by the Apple Developer Portal.")
          UI.important("To fix this a unique (internal) name '#{app.name}' has been created for you. Your app's real name '#{Produce.config[:app_name]}'")
          UI.important("will still show up correctly on App Store Connect and the App Store.")
        end

        UI.message("Created app #{app.app_id}")

        UI.crash!("Something went wrong when creating the new app - it's not listed in the apps list") unless app_exists?

        ENV["CREATED_NEW_APP_ID"] = Time.now.to_i.to_s

        UI.success("Finished creating new app '#{app_name}' on the Dev Center")
      end

      return true
    end

    def enable_services
      app_service = Spaceship.app_service
      enabled_clean_options = {}

      # "enabled_features" was deprecated in favor of "enable_services"
      config_enabled_services = Produce.config[:enable_services] || Produce.config[:enabled_features]

      config_enabled_services.each do |k, v|
        key = k.to_sym
        next if connect_api_only_service?(key)

        if key == :data_protection
          case v
          when SERVICE_COMPLETE
            enabled_clean_options[app_service.data_protection.complete.service_id] = app_service.data_protection.complete
          when SERVICE_UNLESS_OPEN
            enabled_clean_options[app_service.data_protection.unlessopen.service_id] = app_service.data_protection.unlessopen
          when SERVICE_UNTIL_FIRST_LAUNCH
            enabled_clean_options[app_service.data_protection.untilfirstauth.service_id] = app_service.data_protection.untilfirstauth
          end
        elsif key == :icloud
          case v
          when SERVICE_LEGACY
            enabled_clean_options[app_service.cloud.on.service_id] = app_service.cloud.on
            enabled_clean_options[app_service.cloud_kit.xcode5_compatible.service_id] = app_service.cloud_kit.xcode5_compatible
          when SERVICE_CLOUDKIT
            enabled_clean_options[app_service.cloud.on.service_id] = app_service.cloud.on
            enabled_clean_options[app_service.cloud_kit.cloud_kit.service_id] = app_service.cloud_kit.cloud_kit
          end
        else
          if v == SERVICE_ON
            enabled_clean_options[app_service.send(k.to_s).on.service_id] = app_service.send(k.to_s).on
          else
            enabled_clean_options[app_service.send(k.to_s).off.service_id] = app_service.send(k.to_s).off
          end
        end
      end
      enabled_clean_options
    end

    def enable_connect_api_services
      config_enabled_services = Produce.config[:enable_services] || Produce.config[:enabled_features] || {}
      connect_services = config_enabled_services.select do |k, _v|
        connect_api_only_service?(k.to_sym)
      end
      return if connect_services.empty?

      enabled_service_names = connect_services.select { |_k, v| service_enabled?(v) }.keys
      disabled_service_names = connect_services.select { |_k, v| service_disabled?(v) }.keys

      UI.message("Configuring App Store Connect API capabilities for '#{app_identifier}'")
      UI.message("\tenabling: #{enabled_service_names.join(', ')}") unless enabled_service_names.empty?
      UI.message("\tdisabling: #{disabled_service_names.join(', ')}") unless disabled_service_names.empty?

      wait_for_connect_api_bundle_id

      require_relative "service"

      enabled_services = connect_services.select { |_k, v| service_enabled?(v) }
                                         .map { |k, v| [k.to_sym, normalize_service_value(v)] }
                                         .to_h
      disabled_services = connect_services.select { |_k, v| service_disabled?(v) }
                                          .map { |k, _v| [k.to_sym, SERVICE_OFF] }
                                          .to_h

      unless enabled_services.empty?
        Produce::Service.enable(build_connect_api_service_options(enabled_services), nil)
      end

      unless disabled_services.empty?
        Produce::Service.disable(build_connect_api_service_options(disabled_services), nil)
      end
    end

    def build_connect_api_service_options(services)
      option_class = Class.new
      option_class.attr_accessor(:__hash__)
      ALLOWED_SERVICES.keys.each { |service| option_class.attr_accessor(service) }

      service_object = option_class.new
      service_object.__hash__ = {}

      services.each do |key, value|
        sym_key = key.to_sym
        service_object.__hash__[sym_key] = true
        service_object.send("#{sym_key}=", value)
      end

      service_object
    end

    def service_enabled?(value)
      value == SERVICE_ON || value == true || (value != false && value.to_s != SERVICE_OFF)
    end

    def service_disabled?(value)
      value == SERVICE_OFF || value == false
    end

    def normalize_service_value(value)
      return SERVICE_ON if value == true || value.to_s == SERVICE_ON

      value
    end

    def app_identifier
      Produce.config[:app_identifier].to_s
    end

    def connect_api_only_service?(key)
      ALLOWED_SERVICES.key?(key) && !portal_app_service?(key)
    end

    def portal_app_service?(key)
      key = key.to_sym
      return true if key == :icloud || key == :data_protection

      PORTAL_APP_SERVICE_KEYS.include?(key.to_s)
    end

    private

    def wait_for_connect_api_bundle_id
      counter = 0
      loop do
        bundle_id = Spaceship::ConnectAPI::BundleId.find(app_identifier)
        return bundle_id if bundle_id

        counter += 1
        UI.user_error!("Could not find '#{app_identifier}' on App Store Connect to configure capabilities") if counter >= 10

        UI.message("Waiting for '#{app_identifier}' to be available on App Store Connect...")
        sleep(3)
      end
    end

    def platform
      # This was added to support creation of multiple platforms
      # Produce::ItunesConnect can take an array of platforms to create for App Store Connect
      # but the Developer Center is now platform agnostic so we choose any platform here
      #
      # Platform won't be needed at all in the future when this is change over to use Spaceship::ConnectAPI
      (Produce.config[:platforms] || []).first || Produce.config[:platform]
    end

    def app_exists?
      Spaceship.app.find(app_identifier, mac: platform == "osx") != nil
    end

    def login
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
    end
  end
end
