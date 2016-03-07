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
        Helper.log.info "[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist".red
        return
      end

      Helper.log.info "[DevCenter] App found '#{app.name}'".green
      Helper.log.info "Enabling services"
      enabled = update(true, app, options)
      Helper.log.info "Done! Enabled #{enabled} services.".green
    end

    def disable(options, _args)
      unless app
        Helper.log.info "[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist".red
        return
      end

      Helper.log.info "[DevCenter] App found '#{app.name}'".green
      Helper.log.info "Disabling services"
      disabled = update(false, app, options)
      Helper.log.info "Done! Disabled #{disabled} services.".green
    end

    def valid_services_for(options)
      allowed_keys = [:app_group, :associated_domains, :data_protection, :healthkit, :homekit,
                      :wireless_conf, :icloud, :inter_app_audio, :passbook, :push_notification, :vpn_conf]
      options.__hash__.select { |key, value| allowed_keys.include? key }
    end

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def update(on, app, options)
      updated = valid_services_for(options).count

      if options.app_group
        Helper.log.info "\tApp Groups"

        if on
          app.update_service(Spaceship.app_service.app_group.on)
        else
          app.update_service(Spaceship.app_service.app_group.off)
        end
      end

      if options.associated_domains
        Helper.log.info "\tAssociated Domains"

        if on
          app.update_service(Spaceship.app_service.associated_domains.on)
        else
          app.update_service(Spaceship.app_service.associated_domains.off)
        end
      end

      if options.data_protection
        Helper.log.info "\tData Protection"

        if on
          case options.data_protection
          when "complete"
            app.update_service(Spaceship.app_service.data_protection.complete)
          when "unlessopen"
            app.update_service(Spaceship.app_service.data_proection.unless_open)
          when "untilfirstauth"
            app.update_service(Spaceship.app_service.data_protection.until_first_auth)
          else
            raise "Unknown service '#{options.data_protection}'. Valid values: 'complete', 'unlessopen', 'untilfirstauth'".red
          end
        else
          app.update_service(Spaceship.app_service.data_protection.off)
        end
      end

      if options.healthkit
        Helper.log.info "\tHealthKit"

        if on
          app.update_service(Spaceship.app_service.health_kit.on)
        else
          app.update_service(Spaceship.app_service.health_kit.off)
        end
      end

      if options.homekit
        Helper.log.info "\tHomeKit"

        if on
          app.update_service(Spaceship.app_service.home_kit.on)
        else
          app.update_service(Spaceship.app_service.home_kit.off)
        end
      end

      if options.wireless_conf
        Helper.log.info "\tWireless Accessory Configuration"

        if on
          app.update_service(Spaceship.app_service.wireless_accessory.on)
        else
          app.update_service(Spaceship.app_service.wireless_accessory.off)
        end
      end

      if options.icloud
        Helper.log.info "\tiCloud"

        if on
          case options.icloud
          when "legacy"
            app.update_service(Spaceship.app_service.icloud.on)
            app.update_service(Spaceship.app_service.cloud_kit.xcode5_compatible)
          when "cloudkit"
            app.update_service(Spaceship.app_service.icloud.on)
            app.update_service(Spaceship.app_service.cloud_kit.cloud_kit)
          else
            raise "Unknown service '#{options.icloud}'. Valid values: 'legacy', 'cloudkit'".red
          end
        else
          app.update_service(Spaceship.app_service.icloud.off)
        end
      end

      if options.inter_app_audio
        Helper.log.info "\tInter-App Audio"

        if on
          app.update_service(Spaceship.app_service.inter_app_audio.on)
        else
          app.update_service(Spaceship.app_service.inter_app_audio.off)
        end
      end

      if options.passbook
        Helper.log.info "\tPassbook"

        if on
          app.update_service(Spaceship.app_service.passbook.on)
        else
          app.update_service(Spaceship.app_service.passbook.off)
        end
      end

      if options.push_notification
        Helper.log.info "\tPush Notifications"

        if on
          app.update_service(Spaceship.app_service.push_notification.on)
        else
          app.update_service(Spaceship.app_service.push_notification.off)
        end
      end

      if options.vpn_conf
        Helper.log.info "\tVPN Configuration"

        if on
          app.update_service(Spaceship.app_service.vpn_configuration.on)
        else
          app.update_service(Spaceship.app_service.vpn_configuration.off)
        end
      end

      updated
    end

    def app
      return @app if @app

      Helper.log.info "Starting login with user '#{Produce.config[:username]}'"
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      Helper.log.info "Successfully logged in"

      @app ||= Spaceship.app.find(Produce.config[:app_identifier].to_s)
    end
  end
end
