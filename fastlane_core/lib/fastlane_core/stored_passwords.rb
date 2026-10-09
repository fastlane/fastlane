require_relative 'env'

module FastlaneCore
  # Items added with `security add-internet-password` trust /usr/bin/security, so any program
  # running as the user can read them (#29712): passwords are only stored when asked to.
  module StoredPasswords
    STORE_ENV = "FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN"

    # FASTLANE_DONT_STORE_PASSWORD, any value, still prevents storing
    def self.store?
      return false if ENV["FASTLANE_DONT_STORE_PASSWORD"]
      Env.truthy?(STORE_ENV)
    end

    # The warning to print when a password was read from a keychain item fastlane stored, once per item and run
    def self.read_warning(item, what:, remove_with:, instead:)
      @warned ||= {}
      return nil if @warned[item]
      @warned[item] = true

      ["Read #{what} from the keychain item '#{item}', which any program running as you can read.",
       "Remove it with `#{remove_with}`, and #{instead}."]
    end

    def self.reset_warnings!
      @warned = nil
    end
  end
end
