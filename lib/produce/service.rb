module Produce
  class Service
    def self.enable(options, args)
      self.new.enable(options, args)
    end

    def self.disable(options, args)
      self.new.disable(options, args)
    end

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

      enabled = 0

      if options.app_group
        app.update_service(Spaceship.app_service.app_group.on)
        enabled += 1
        Helper.log.info "Enabled App Groups"
      end

      if options.associated_domains
        app.update_service(Spaceship.app_service.associated_domains.on)
        enabled += 1
        Helper.log.info "Enable Associated Domains"
      end

      if options.data_protection
        case options.data_protection
          when "complete"
            app.update_service(Spaceship.app_service.data_protection.complete)
            enabled += 1
            Helper.log.info "Enabled Data Protection: Complete"
          when "unlessopen"
            app.update_service(Spaceship.app_service.data_proection.unless_open)
            enabled += 1
            Helper.log.info "Enabled Data Protection: Unless Open"
          when "untilfirstauth"
            app.update_service(Spaceship.app_service.data_protection.until_first_auth)
            enabled += 1
            Helper.log.info "Enabled Data Protection: Until First Authentication"
        end
      end

      if options.healthkit
        app.update_service(Spaceship.app_service.health_kit.on)
        enabled += 1
        Helper.log.info "Enabled HealthKit"
      end

      if options.homekit
        app.update_service(Spaceship.app_service.home_kit.on)
        enabled += 1
        Helper.log.info "Enabled HomeKit"
      end

      if options.wireless_conf
        app.update_service(Spaceship.app_service.wireless_accessory.on)
        enabled += 1
        Helper.log.info "Enable Wireless Accessory Configuration"
      end

      if options.icloud
        case options.icloud
        when "legacy"
          app.update_service(Spaceship.app_service.icloud.on)
          app.update_service(Spaceship.app_service.cloud_kit.xcode5_compatible)
          enabled += 1
          Helper.log.info "Enabled iCloud: CloudKit"
        when "cloudkit"
          app.update_service(Spaceship.app_service.icloud.on)
          app.update_service(Spaceship.app_service.cloud_kit.cloud_kit)
          enabled += 1
          Helper.log.info "Enabled iCloud: CloudKit"
        end
      end

      if options.inter_app_audio
        app.update_service(Spaceship.app_service.inter_app_audio.on)
        enabled += 1
        Helper.log.info "Enabled Inter-App Audio"
      end

      if options.passbook
        app.update_service(Spaceship.app_service.passbook.on)
        enabled += 1
        Helper.log.info "Enabled Passbook"
      end

      if options.push_notification
        app.update_service(Spaceship.app_service.push_notification.on)
        enabled += 1
        Helper.log.info "Enabled Push Notifications"
      end

      if options.vpn_conf
        app.update_service(Spaceship.app_service.vpn_configuration.on)
        enabled += 1
        Helper.log.info "Enabled VPN Configuration"
      end

      Helper.log.info "Done! Enabled #{enabled} services.".green
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

      disabled = 0

      if options.app_group
        app.update_service(Spaceship.app_service.app_group.off)
        disabled += 1
        Helper.log.info "Disabled App Groups"
      end

      if options.associated_domains
        app.update_service(Spaceship.app_service.associated_domains.off)
        disabled += 1
        Helper.log.info "Disabled Associated Domains"
      end

      if options.data_protection
        app.update_service(Spaceship.app_service.data_protection.off)
        disabled += 1
        Helper.log.info "Disabled Data Protection"
      end

      if options.healthkit
        app.update_service(Spaceship.app_service.health_kit.off)
        disabled += 1
        Helper.log.info "Disabled HealthKit"
      end

      if options.homekit
        app.update_service(Spaceship.app_service.home_kit.off)
        disabled += 1
        Helper.log.info "Disabled HomeKit"
      end

      if options.wireless_conf
        app.update_service(Spaceship.app_service.wireless_accessory.off)
        disabled += 1
        Helper.log.info "Disabled Wireless Accessory Configuration"
      end

      if options.icloud
        app.update_service(Spaceship.app_service.icloud.off)
        disabled += 1
        Helper.log.info "Disabled iCloud"
      end

      if options.inter_app_audio
        app.update_service(Spaceship.app_service.inter_app_audio.off)
        disabled += 1
        Helper.log.info "Disabled Inter-App Audio"
      end

      if options.passbook
        app.update_service(Spaceship.app_service.passbook.off)
        disabled += 1
        Helper.log.info "Disabled Passbook"
      end

      if options.push_notification
        app.update_service(Spaceship.app_service.push_notification.off)
        disabled += 1
        Helper.log.info "Disabled Push Notifications"
      end

      if options.vpn_conf
        app.update_service(Spaceship.app_service.vpn_configuration.off)
        disabled += 1
        Helper.log.info "Disabled VPN Configuration"
      end

      Helper.log.info "Done! Disabled #{disabled} services.".green
    end
  end
end
