require 'spaceship'
require_relative 'module'

module Produce
  class Service
    def self.enable(options, args)
      self.new.enable(options, args)
    end

    def self.disable(options, args)
      self.new.disable(options, args)
    end

    def enable(options, _args)
      unless app
        UI.message("[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist")
        return
      end

      UI.success("[DevCenter] App found '#{app.name}'")
      UI.message("Enabling services")
      enabled = update(true, app, options)
      UI.success("Done! Enabled #{enabled} services.")
    end

    def disable(options, _args)
      unless app
        UI.message("[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist")
        return
      end

      UI.success("[DevCenter] App found '#{app.name}'")
      UI.message("Disabling services")
      disabled = update(false, app, options)
      UI.success("Done! Disabled #{disabled} services.")
    end

    def valid_services_for(options)
      allowed_keys = [:access_wifi, :app_attest, :app_group, :apple_pay, :associated_domains, :auto_fill_credential, :car_play_audio_app, :car_play_messaging_app,
                      :car_play_navigation_app, :car_play_voip_calling_app, :class_kit, :icloud, :critical_alerts, :custom_network_protocol, :data_protection,
                      :extended_virtual_address_space, :file_provider_testing_mode, :fonts, :game_center, :health_kit, :hls_interstitial_preview, :home_kit, :hotspot,
                      :hotspot_helper, :in_app_purchase, :inter_app_audio, :low_latency_hls, :managed_associated_domains, :maps, :multipath, :network_extension,
                      :nfc_tag_reading, :passbook, :personal_vpn, :push_notification, :sign_in_with_apple, :siri_kit, :system_extension, :user_management, :vpn_configuration, :wallet,
                      :wireless_accessory]
      options.__hash__.select { |key, value| allowed_keys.include?(key) }
    end

    # rubocop:disable Metrics/PerceivedComplexity
    def update(on, app, options)
      updated = valid_services_for(options).count

      if options.access_wifi
        UI.message("\tAccess WiFi")
        if on
          app.update_service(Spaceship.app_service.access_wifi.on)
        else
          app.update_service(Spaceship.app_service.access_wifi.off)
        end
      end

      if options.access_wifi
        UI.message("\tApp Attest")
        if on
          app.update_service(Spaceship.app_service.app_attest.on)
        else
          app.update_service(Spaceship.app_service.app_attest.off)
        end
      end

      if options.app_group
        UI.message("\tApp Groups")

        if on
          app.update_service(Spaceship.app_service.app_group.on)
        else
          app.update_service(Spaceship.app_service.app_group.off)
        end
      end

      if options.apple_pay
        UI.message("\tApple Pay")

        if on
          app.update_service(Spaceship.app_service.apple_pay.on)
        else
          app.update_service(Spaceship.app_service.apple_pay.off)
        end
      end

      if options.associated_domains
        UI.message("\tAssociated Domains")

        if on
          app.update_service(Spaceship.app_service.associated_domains.on)
        else
          app.update_service(Spaceship.app_service.associated_domains.off)
        end
      end

      if options.auto_fill_credential
        UI.message("\tAutoFill Credential")

        if on
          app.update_service(Spaceship.app_service.auto_fill_credential.on)
        else
          app.update_service(Spaceship.app_service.auto_fill_credential.off)
        end
      end

      if options.car_play_audio_app
        UI.message("\tCarPlay Audio App")

        if on
          app.update_service(Spaceship.app_service.car_play_audio_app.on)
        else
          app.update_service(Spaceship.app_service.car_play_audio_app.off)
        end
      end

      if options.car_play_messaging_app
        UI.message("\tCarPlay Messaging App")

        if on
          app.update_service(Spaceship.app_service.car_play_messaging_app.on)
        else
          app.update_service(Spaceship.app_service.car_play_messaging_app.off)
        end
      end

      if options.car_play_navigation_app
        UI.message("\tCarPlay Navigation App")

        if on
          app.update_service(Spaceship.app_service.car_play_navigation_app.on)
        else
          app.update_service(Spaceship.app_service.car_play_navigation_app.off)
        end
      end

      if options.car_play_voip_calling_app
        UI.message("\tCarPlay Voip Calling App")

        if on
          app.update_service(Spaceship.app_service.car_play_voip_calling_app.on)
        else
          app.update_service(Spaceship.app_service.car_play_voip_calling_app.off)
        end
      end

      if options.class_kit
        UI.message("\tClassKit")

        if on
          app.update_service(Spaceship.app_service.class_kit.on)
        else
          app.update_service(Spaceship.app_service.class_kit.off)
        end
      end

      if options.critical_alerts
        UI.message("\tCritical Alerts")

        if on
          app.update_service(Spaceship.app_service.critical_alerts.on)
        else
          app.update_service(Spaceship.app_service.critical_alerts.off)
        end
      end

      if options.custom_network_protocol
        UI.message("\tCustom Network Protocol")

        if on
          app.update_service(Spaceship.app_service.custom_network_protocol.on)
        else
          app.update_service(Spaceship.app_service.custom_network_protocol.off)
        end
      end

      if options.data_protection
        UI.message("\tData Protection")

        if on
          case options.data_protection
          when "complete"
            app.update_service(Spaceship.app_service.data_protection.complete)
          when "unlessopen"
            app.update_service(Spaceship.app_service.data_protection.unless_open)
          when "untilfirstauth"
            app.update_service(Spaceship.app_service.data_protection.until_first_auth)
          else
            UI.user_error!("Unknown service '#{options.data_protection}'. Valid values: 'complete', 'unlessopen', 'untilfirstauth'")
          end
        else
          app.update_service(Spaceship.app_service.data_protection.off)
        end
      end

      if options.extended_virtual_address_space
        UI.message("\tExtended Virtual Address Space")

        if on
          app.update_service(Spaceship.app_service.extended_virtual_address_space.on)
        else
          app.update_service(Spaceship.app_service.extended_virtual_address_space.off)
        end
      end

      if options.file_provider_testing_mode
        UI.message("\tFile Provider Testing Mode")

        if on
          app.update_service(Spaceship.app_service.file_provider_testing_mode.on)
        else
          app.update_service(Spaceship.app_service.file_provider_testing_mode.off)
        end
      end

      if options.fonts
        UI.message("\tFonts")

        if on
          app.update_service(Spaceship.app_service.fonts.on)
        else
          app.update_service(Spaceship.app_service.fonts.off)
        end
      end

      if options.game_center
        UI.message("\tGame Center")

        if on
          case options.game_center
          when "macos"
            app.update_service(Spaceship.app_service.game_center.macos)
          when "ios"
            app.update_service(Spaceship.app_service.game_center.ios)
          else
            UI.user_error!("Unknown service '#{options.game_center}'. Valid values: 'ios', 'macos', 'off'")
          end
        else
          app.update_service(Spaceship.app_service.game_center.off)
        end
      end

      if options.healthkit
        UI.message("\tHealthKit")

        if on
          app.update_service(Spaceship.app_service.health_kit.on)
        else
          app.update_service(Spaceship.app_service.health_kit.off)
        end
      end

      if options.hls_interstitial_preview
        UI.message("\tHLS Interstitial Preview")

        if on
          app.update_service(Spaceship.app_service.hls_interstitial_preview.on)
        else
          app.update_service(Spaceship.app_service.hls_interstitial_preview.off)
        end
      end

      if options.homekit
        UI.message("\tHomeKit")

        if on
          app.update_service(Spaceship.app_service.home_kit.on)
        else
          app.update_service(Spaceship.app_service.home_kit.off)
        end
      end

      if options.hotspot
        UI.message("\tHotspot")

        if on
          app.update_service(Spaceship.app_service.hotspot.on)
        else
          app.update_service(Spaceship.app_service.hotspot.off)
        end
      end

      if options.hotspot_helper
        UI.message("\tHotspot Helper")

        if on
          app.update_service(Spaceship.app_service.hotspot_helper.on)
        else
          app.update_service(Spaceship.app_service.hotspot_helper.off)
        end
      end

      if options.icloud
        UI.message("\tiCloud")

        if on
          case options.icloud
          when "xcode6_compatible"
            app.update_service(Spaceship.app_service.cloud.xcode6_compatible)
          when "xcode5_compatible"
            app.update_service(Spaceship.app_service.cloud.xcode5_compatible)
          else
            UI.user_error!("Unknown service '#{options.icloud}'. Valid values: 'xcode6_compatible', 'xcode5_compatible', 'off'")
          end
        else
          app.update_service(Spaceship.app_service.cloud.off)
        end
      end

      if options.in_app_purchase
        UI.message("\tIn-App Purchase")

        if on
          app.update_service(Spaceship.app_service.in_app_purchase.on)
        else
          app.update_service(Spaceship.app_service.in_app_purchase.off)
        end
      end

      if options.inter_app_audio
        UI.message("\tInter-App Audio")

        if on
          app.update_service(Spaceship.app_service.inter_app_audio.on)
        else
          app.update_service(Spaceship.app_service.inter_app_audio.off)
        end
      end

      if options.low_latency_hls
        UI.message("\tLow Latency HLS")

        if on
          app.update_service(Spaceship.app_service.low_latency_hls.on)
        else
          app.update_service(Spaceship.app_service.low_latency_hls.off)
        end
      end

      if options.managed_associated_domains
        UI.message("\tManaged Associated Domains")

        if on
          app.update_service(Spaceship.app_service.managed_associated_domains.on)
        else
          app.update_service(Spaceship.app_service.managed_associated_domains.off)
        end
      end

      if options.maps
        UI.message("\tMaps")

        if on
          app.update_service(Spaceship.app_service.maps.on)
        else
          app.update_service(Spaceship.app_service.maps.off)
        end
      end

      if options.multipath
        UI.message("\tMultipath")

        if on
          app.update_service(Spaceship.app_service.multipath.on)
        else
          app.update_service(Spaceship.app_service.multipath.off)
        end
      end

      if options.network_extension
        UI.message("\tNetwork Extension")

        if on
          app.update_service(Spaceship.app_service.network_extension.on)
        else
          app.update_service(Spaceship.app_service.network_extension.off)
        end
      end

      if options.nfc_tag_reading
        UI.message("\tNFC Tag Reading")

        if on
          app.update_service(Spaceship.app_service.nfc_tag_reading.on)
        else
          app.update_service(Spaceship.app_service.nfc_tag_reading.off)
        end
      end

      # deprecated
      if options.passbook
        UI.message("\tPassbook")

        if on
          app.update_service(Spaceship.app_service.passbook.on)
        else
          app.update_service(Spaceship.app_service.passbook.off)
        end
      end

      if options.personal_vpn
        UI.message("\tPersonal VPN")

        if on
          app.update_service(Spaceship.app_service.personal_vpn.on)
        else
          app.update_service(Spaceship.app_service.personal_vpn.off)
        end
      end

      if options.push_notification
        UI.message("\tPush Notifications")

        if on
          # Don't enable push notifications if already enabled
          # Enabling push notifications when already on revokes certs
          # https://github.com/fastlane/fastlane/issues/15315
          # https://github.com/fastlane/fastlane/issues/8883
          unless app.details.enable_services.include?("push")
            app.update_service(Spaceship.app_service.push_notification.on)
          end
        else
          app.update_service(Spaceship.app_service.push_notification.off)
        end
      end

      if options.sign_in_with_apple
        UI.message("\tSign In With Apple")

        if on
          app.update_service(Spaceship.app_service.sign_in_with_apple.on)
        else
          app.update_service(Spaceship.app_service.sign_in_with_apple.off)
        end
      end

      if options.sirikit
        UI.message("\tSiriKit")

        if on
          app.update_service(Spaceship.app_service.siri_kit.on)
        else
          app.update_service(Spaceship.app_service.siri_kit.off)
        end
      end

      if options.system_extension
        UI.message("\tSystem Extension")

        if on
          app.update_service(Spaceship.app_service.system_extension.on)
        else
          app.update_service(Spaceship.app_service.system_extension.off)
        end
      end

      if options.user_management
        UI.message("\tUser Management")

        if on
          app.update_service(Spaceship.app_service.user_management.on)
        else
          app.update_service(Spaceship.app_service.user_management.off)
        end
      end

      # deprecated
      if options.vpn_conf
        UI.message("\tVPN Configuration")

        if on
          app.update_service(Spaceship.app_service.vpn_configuration.on)
        else
          app.update_service(Spaceship.app_service.vpn_configuration.off)
        end
      end

      if options.wallet
        UI.message("\tWallet")

        if on
          app.update_service(Spaceship.app_service.wallet.on)
        else
          app.update_service(Spaceship.app_service.wallet.off)
        end
      end

      if options.wireless_conf
        UI.message("\tWireless Accessory Configuration")

        if on
          app.update_service(Spaceship.app_service.wireless_accessory.on)
        else
          app.update_service(Spaceship.app_service.wireless_accessory.off)
        end
      end

      updated
    end

    def app
      return @app if @app

      UI.message("Starting login with user '#{Produce.config[:username]}'")
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")

      @app ||= Spaceship.app.find(Produce.config[:app_identifier].to_s)
    end
  end
end
