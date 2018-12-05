require 'spaceship'
require_relative 'module'

module Produce
  class Merchant
    def create(_options, _args)
      login

      merchant_identifier = detect_merchant_identifier
      merchant = find_merchant(merchant_identifier)

      if merchant
        UI.success("[DevCenter] Merchant '#{merchant.bundle_id})' already exists, nothing to do on the Dev Center")
      else
        merchant_name = Produce.config[:merchant_name] || merchant_name_from_identifier(merchant_identifier)
        UI.success("Creating new merchant '#{merchant_name}' with identifier '#{merchant_identifier}' on the Apple Dev Center")
        merchant = Spaceship.merchant.create!(bundle_id: merchant_identifier, name: merchant_name, mac: self.class.mac?)

        if merchant.name != merchant_name
          UI.important("Your merchant name might include non-ASCII characters, which are not supported by the Apple Developer Portal.")
          UI.important("To fix this a unique (internal) name '#{merchant.name}' has been created for you.")
        end

        UI.message("Created merchant #{merchant.merchant_id}")
        UI.success("Finished creating new merchant '#{merchant_name}' on the Dev Center")
      end
    end

    def associate(_options, args)
      login

      app = Spaceship.app.find(app_identifier)

      if app
        app.update_service(Spaceship.app_service.apple_pay.on)

        UI.message("Validating merchants before association")

        # associate requires identifiers to exist. This splits the provided identifiers into existing/non-existing. See: https://ruby-doc.org/core/Enumerable.html#method-i-partition
        valid_identifiers, errored_identifiers = args.partition { |identifier| merchant_exists?(identifier) }
        new_merchants = valid_identifiers.map { |identifier| find_merchant(identifier) }

        errored_identifiers.each do |merchant_identifier|
          UI.message("[DevCenter] Merchant '#{merchant_identifier}' does not exist, please create it first, skipping for now")
        end

        UI.message("Finalising association with #{new_merchants.count} #{pluralize('merchant', new_merchants)}")
        app.associate_merchants(new_merchants)
        UI.success("Done!")
      else
        UI.message("[DevCenter] App '#{Produce.config[:app_identifier]}' does not exist, nothing to associate with the merchants")
      end
    end

    def login
      UI.message("Starting login with user '#{Produce.config[:username]}'")
      Spaceship.login(Produce.config[:username], nil)
      Spaceship.select_team
      UI.message("Successfully logged in")
    end

    def app_identifier
      Produce.config[:app_identifier]
    end

    def pluralize(singular, arr)
      return singular if arr.count == 1

      "#{singular}s"
    end

    def merchant_exists?(identifier)
      find_merchant(identifier)
    end

    def detect_merchant_identifier
      self.class.detect_merchant_identifier
    end

    def self.detect_merchant_identifier(config = Produce.config)
      identifier = config[:merchant_identifier] || input("Merchant identifier (reverse-domain name style string starting with 'merchant'): ", ":merchant_identifier option is required")
      prepare_identifier(identifier)
    end

    def self.input(message, error_message)
      if UI.interactive?
        UI.input(message)
      else
        UI.user_error!(error_message)
      end
    end

    def self.prepare_identifier(identifier)
      return identifier if identifier.start_with?("merchant.")

      "merchant.#{identifier}"
    end

    def find_merchant(identifier)
      self.class.find_merchant(identifier)
    end

    def self.find_merchant(identifier, merchant: Spaceship.merchant)
      @cache ||= {}
      @cache[identifier] ||= merchant.find(identifier, mac: mac?)
    end

    def self.mac?(config = Produce.config)
      config[:platform].to_s == "mac"
    end

    def merchant_name_from_identifier(identifier)
      self.class.merchant_name_from_identifier(identifier)
    end

    def self.merchant_name_from_identifier(identifier)
      capitalized_words = identifier.split(".").map(&:capitalize)
      capitalized_words.reverse.join(' ')
    end
  end
end
