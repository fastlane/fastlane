require 'fastlane_core/keychain_importer'
require_relative 'module'

module Match
  class Utils
    def self.import(item_path, keychain, password: "")
      keychain_path = FastlaneCore::Helper.keychain_path(keychain)
      FastlaneCore::KeychainImporter.import_file(item_path, keychain_path, keychain_password: password, output: FastlaneCore::Globals.verbose?)
    end

    # Fill in an environment variable, ready to be used in _xcodebuild_
    def self.fill_environment(key, value)
      UI.important("Setting environment variable '#{key}' to '#{value}'") if FastlaneCore::Globals.verbose?
      ENV[key] = value
    end

    def self.environment_variable_name(app_identifier: nil, type: nil, platform: :ios)
      base_environment_variable_name(app_identifier: app_identifier, type: type, platform: platform).join("_")
    end

    def self.environment_variable_name_team_id(app_identifier: nil, type: nil, platform: :ios)
      (base_environment_variable_name(app_identifier: app_identifier, type: type, platform: platform) + ["team-id"]).join("_")
    end

    def self.environment_variable_name_profile_name(app_identifier: nil, type: nil, platform: :ios)
      (base_environment_variable_name(app_identifier: app_identifier, type: type, platform: platform) + ["profile-name"]).join("_")
    end

    def self.environment_variable_name_profile_path(app_identifier: nil, type: nil, platform: :ios)
      (base_environment_variable_name(app_identifier: app_identifier, type: type, platform: platform) + ["profile-path"]).join("_")
    end

    def self.get_cert_info(cer_certificate_path)
      command = "openssl x509 -inform der -in #{cer_certificate_path.shellescape} -subject -dates -noout"
      command << " &" # start in separate process
      output = Helper.backticks(command, print: FastlaneCore::Globals.verbose?)

      # openssl output:
      # subject= /UID={User ID}/CN={Certificate Name}/OU={Certificate User}/O={Organisation}/C={Country}\n
      # notBefore={Start datetime}\n
      # notAfter={End datetime}
      cert_info = output.gsub(/\s*subject=\s*/, "").tr("/", "\n")
      out_array = cert_info.split("\n")
      openssl_keys_to_readable_keys = {
           'UID' => 'User ID',
           'CN' => 'Common Name',
           'OU' => 'Organisation Unit',
           'O' => 'Organisation',
           'C' => 'Country',
           'notBefore' => 'Start Datetime',
           'notAfter' => 'End Datetime'
       }

      return out_array.map { |x| x.split(/=+/) if x.include?("=") }
                      .compact
                      .map { |k, v| [openssl_keys_to_readable_keys.fetch(k, k), v] }
    rescue => ex
      UI.error(ex)
      return {}
    end

    def self.base_environment_variable_name(app_identifier: nil, type: nil, platform: :ios)
      if platform.to_s == :ios.to_s
        ["sigh", app_identifier, type] # We keep the ios profiles without the platform for backwards compatibility
      else
        ["sigh", app_identifier, type, platform.to_s]
      end
    end
  end
end
