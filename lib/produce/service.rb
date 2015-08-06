module Produce
  class Service
    def enable(options, args)
      Helper.log.info "Starting login"
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"

      app = Spaceship.app.find(Produce.config[:app_identifier].to_s)

      if app.nil?
        Helper.log.info "[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist".red
        return
      end

      Helper.log.info "[DevCenter] App found '#{app.name}'".green
      Helper.log.info "Proceeding with enabling services"

      if options.app_group
        app.update_service(Spaceship.app_service.app_group.on)
        Helper.log.info "Enabled App Groups"
      end

      if options.associated_domains
        app.update_service(Spaceship.app_service.associated_domains.on)
        Helper.log.info "Enable Associated Domains"
      end

      if options.data_protection
        case options.data_protection
          when "complete"
            app.update_service(Spaceship.app_service.data_protection.complete)
            Helper.log.info "Enabled Data Protection: Complete"
          when "unlessopen"
            app.update_service(Spaceship.app_service.data_proection.unless_open)
            Helper.log.info "Enabled Data Protection: Unless Open"
          when "untilfirstauth"
            app.update_service(Spaceship.app_service.data_protection.until_first_auth)
            Helper.log.info "Enabled Data Protection: Until First Authentication"
        end
      end

      if options.healthkit
        app.update_service(Spaceship.app_service.health_kit.on)
        Helper.log.info "Enabled HealthKit"
      end

      if options.homekit
        app.update_service(Spaceship.app_service.home_kit.on)
        Helper.log.info "Enabled HomeKit"
      end

      if options.wireless_conf
        app.update_service(Spaceship.app_service.wireless_accessory.on)
        Helper.log.info "Enable Wireless Accessory Configuration"
      end

      if options.icloud
        case options.icloud
        when "legacy"
          app.update_service(Spaceship.app_service.icloud.on)
          app.update_service(Spaceship.app_service.cloud_kit.xcode5_compatible)
          Helper.log.info "Enabled iCloud: CloudKit"
        when "cloudkit"
          app.update_service(Spaceship.app_service.icloud.on)
          app.update_service(Spaceship.app_service.cloud_kit.cloud_kit)
          Helper.log.info "Enabled iCloud: CloudKit"
        end
      end

      if options.inter_app_audio
        app.update_service(Spaceship.app_service.inter_app_audio.on)
        Helper.log.info "Enabled Inter-App Audio"
      end

      if options.passbook
        app.update_service(Spaceship.app_service.passbook.on)
        Helper.log.info "Enabled Passbook"
      end

      if options.push_notification
        app.update_service(Spaceship.app_service.push_notification.on)
        Helper.log.info "Enabled Push Notifications"
      end

      if options.vpn_conf
        app.update_service(Spaceship.app_service.vpn_configuration.on)
        Helper.log.info "Enabled VPN Configuration"
      end
    end

    def disable(options, args)
      Helper.log.info "Starting login"
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"

      app = Spaceship.app.find(Produce.config[:app_identifier].to_s)

      if app.nil?
        Helper.log.info "[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist".red
        return
      end

      Helper.log.info "[DevCenter] App found '#{app.name}'".green
      Helper.log.info "Proceeding with disabling services"

      if options.app_group
        app.update_service(Spaceship.app_service.app_group.off)
        Helper.log.info "Disabled App Groups"
      end

      if options.associated_domains
        app.update_service(Spaceship.app_service.associated_domains.off)
        Helper.log.info "Disabled Associated Domains"
      end

      if options.data_protection
        app.update_service(Spaceship.app_service.data_protection.off)
        Helper.log.info "Disabled Data Protection"
      end

      if options.healthkit
        app.update_service(Spaceship.app_service.health_kit.off)
        Helper.log.info "Disabled HealthKit"
      end

      if options.homekit
        app.update_service(Spaceship.app_service.home_kit.off)
        Helper.log.info "Disabled HomeKit"
      end

      if options.wireless_conf
        app.update_service(Spaceship.app_service.wireless_accessory.off)
        Helper.log.info "Disabled Wireless Accessory Configuration"
      end

      if options.icloud
        app.update_service(Spaceship.app_service.icloud.off)
        Helper.log.info "Disabled iCloud"
      end

      if options.inter_app_audio
        app.update_service(Spaceship.app_service.inter_app_audio.off)
        Helper.log.info "Disabled Inter-App Audio"
      end

      if options.passbook
        app.update_service(Spaceship.app_service.passbook.off)
        Helper.log.info "Disabled Passbook"
      end

      if options.push_notification
        app.update_service(Spaceship.app_service.push_notification.off)
        Helper.log.info "Disabled Push Notifications"
      end

      if options.vpn_conf
        app.update_service(Spaceship.app_service.vpn_configuration.off)
        Helper.log.info "Disabled VPN Configuration"
      end
    end
  end
end
