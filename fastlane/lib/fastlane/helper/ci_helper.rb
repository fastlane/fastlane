module Fastlane
  module Helper
    class CI
      def self.should_run?(force: false)
        Helper.ci? || force
      end

      def self.setup_keychain
        unless ENV["MATCH_KEYCHAIN_NAME"].nil?
          UI.message("Skipping Keychain setup as a keychain was already specified")
          return
        end

        keychain_name = "fastlane_tmp_keychain"
        ENV["MATCH_KEYCHAIN_NAME"] = keychain_name
        ENV["MATCH_KEYCHAIN_PASSWORD"] = ""

        UI.message("Creating temporary keychain: \"#{keychain_name}\".")
        Actions::CreateKeychainAction.run(
          name: keychain_name,
          default_keychain: true,
          unlock: true,
          timeout: 3600,
          lock_when_sleeps: true,
          password: ""
        )

        UI.message("Enabling match readonly mode.")
        ENV["MATCH_READONLY"] = true.to_s
      end
    end
  end
end
