require 'spaceship'

module Produce
  class Merchant
    def create(_options, _args)
      login

      merchant_identifier = Produce.config[:merchant_identifier] || UI.input("Merchant identifier (reverse-domain name style string starting with 'merchant'): ")

      if merchant_exists? merchant_identifier
        UI.success("[DevCenter] Merchant '#{merchant_identifier})' already exists, nothing to do on the Dev Center")
      else
        merchant_name = Produce.config[:merchant_name] || merchant_identifier.split(".").map(&:capitalize).reverse.join(' ')

        UI.success("Creating new merchant '#{merchant_name}' with identifier '#{merchant_identifier}' on the Apple Dev Center")

        merchant = Spaceship.merchant.create!(bundle_id: merchant_identifier,
                                            name: merchant_name,
                                            mac: Produce.config[:platform].to_s == 'mac')

        if merchant.name != merchant_name
          UI.important("Your merchant name includes non-ASCII characters, which are not supported by the Apple Developer Portal.")
          UI.important("To fix this a unique (internal) name '#{merchant.name}' has been created for you.")
        end

        UI.message("Created merchant #{merchant.merchant_id}")
        UI.user_error!("Something went wrong when creating the new merchant - it's not listed in the merchants list") unless merchant_exists? merchant_identifier
        UI.success("Finished creating new merchant '#{merchant_name}' on the Dev Center")
      end

      return true
    end

    def associate(_options, args)
      login

      if !app_exists?
        UI.message("[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist, nothing to associate with the merchants")
      else
        app = Spaceship.app.find(app_identifier)
        UI.user_error!("Something went wrong when fetching the app - it's not listed in the apps list") if app.nil?

        app.update_service(Spaceship.app_service.apple_pay.on)
        new_merchants = []

        UI.message("Validating merchants before association")

        args.each do |merchant_identifier|
          if !merchant_exists?(merchant_identifier)
            UI.message("[DevCenter] Merchant '#{merchant_identifier}' does not exist, please create it first, skipping for now")
          else
            new_merchants.push(Spaceship.merchant.find(merchant_identifier, mac: Produce.config[:platform].to_s == 'mac'))
          end
        end

        UI.message("Finalising association with #{new_merchants.count} #{new_merchants.count != 1 ? 'merchants' : 'merchant'}")
        app.associate_merchants(new_merchants)
        UI.success("Done!")
      end

      return true
    end

    def login
      UI.message("Starting login with user '#{Produce.config[:username]}'")
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")
    end

    def app_identifier
      Produce.config[:app_identifier].to_s
    end

    def merchant_exists?(identifier)
      Spaceship.merchant.find(identifier, mac: Produce.config[:platform].to_s == 'mac') != nil
    end

    def app_exists?
      Spaceship.app.find(app_identifier) != nil
    end
  end
end
