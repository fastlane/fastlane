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
      allowed_keys = [:access_wifi, :app_group, :apple_pay, :associated_domains, :auto_fill_credential, :data_protection, :game_center, :healthkit, :homekit,
                      :hotspot, :icloud, :in_app_purchase, :inter_app_audio, :multipath, :network_extension,
                      :nfc_tag_reading, :personal_vpn, :passbook, :push_notification, :sirikit, :vpn_conf,
                      :wallet, :wireless_conf]
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

      if options.game_center
        UI.message("\tGame Center")

        if on
          app.update_service(Spaceship.app_service.game_center.on)
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

      if options.homekit
        UI.message("\tHomeKit")

        if on
          app.update_service(Spaceship.app_service.home_kit.on)
        else
          app.update_service(Spaceship.app_service.home_kit.off)
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

      if options.icloud
        UI.message("\tiCloud")

        if on
          case options.icloud
          when "legacy"
            app.update_service(Spaceship.app_service.cloud.on)
            app.update_service(Spaceship.app_service.cloud_kit.xcode5_compatible)
          when "cloudkit"
            app.update_service(Spaceship.app_service.cloud.on)
            app.update_service(Spaceship.app_service.cloud_kit.cloud_kit)
          else
            UI.user_error!("Unknown service '#{options.icloud}'. Valid values: 'legacy', 'cloudkit'")
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

      if options.personal_vpn
        UI.message("\tPersonal VPN")

        if on
          app.update_service(Spaceship.app_service.personal_vpn.on)
        else
          app.update_service(Spaceship.app_service.personal_vpn.off)
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

      if options.push_notification
        UI.message("\tPush Notifications")

        if on
          app.update_service(Spaceship.app_service.push_notification.on)
        else
          app.update_service(Spaceship.app_service.push_notification.off)
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

      # deprecated
      if options.vpn_conf
        UI.message("\tVPN Configuration")

        if on
          app.update_service(Spaceship.app_service.vpn_configuration.on)
        else
          app.update_service(Spaceship.app_service.vpn_configuration.off)
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

      if options.hotspot
        UI.message("\tHotspot")

        if on
          app.update_service(Spaceship.app_service.hotspot.on)
        else
          app.update_service(Spaceship.app_service.hotspot.off)
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

      if options.nfc_tag_reading
        UI.message("\tNFC Tag Reading")

        if on
          app.update_service(Spaceship.app_service.nfc_tag_reading.on)
        else
          app.update_service(Spaceship.app_service.nfc_tag_reading.off)
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
