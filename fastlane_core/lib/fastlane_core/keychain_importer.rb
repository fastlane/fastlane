require_relative 'helper'
require 'open3'
require 'security'

module FastlaneCore
  class KeychainImporter
    def self.import_file(path, keychain_path, keychain_password: nil, certificate_password: "", certificate_format: nil, skip_set_partition_list: false, output: FastlaneCore::Globals.verbose?)
      UI.user_error!("Could not find file '#{path}'") unless File.exist?(path)

      certificate_format = nil if certificate_format.to_s.strip.empty?
      UI.command("security import #{path.shellescape} -k #{keychain_path.shellescape} -P ********#{" -f #{certificate_format}" if certificate_format}") if output

      begin
        Security::Certificate.import(path, keychain: keychain_path, password: certificate_password, format: certificate_format)
      rescue Security::DuplicateItemError
        UI.verbose("'#{File.basename(path)}' is already installed on this machine")
        return
      rescue Security::Error => e
        UI.error(e.output.strip)
        return
      end

      # Set partition list only if success since it can be a time consuming process if a lot of keys are installed
      return if skip_set_partition_list

      keychain_password ||= resolve_keychain_password(keychain_path)
      set_partition_list(path, keychain_path, keychain_password: keychain_password, output: output)
    end

    def self.set_partition_list(path, keychain_path, keychain_password: nil, output: FastlaneCore::Globals.verbose?)
      # When security supports partition lists, also add the partition IDs
      # See https://openradar.appspot.com/28524119
      if Helper.backticks('security -h | grep set-key-partition-list', print: false).length > 0
        password_part = " -k #{keychain_password.to_s.shellescape}"

        command = "security set-key-partition-list"
        command << " -S apple-tool:,apple:,codesign:"
        command << " -s" # This is a needed in Catalina to prevent "security: SecKeychainItemCopyAccess: A missing value was detected."
        command << password_part
        command << " #{keychain_path.shellescape}"
        command << " 1> /dev/null" # always disable stdout. This can be very verbose, and leak potentially sensitive info

        # Showing loading indicator as this can take some time if a lot of keys installed
        Helper.with_loading_indicator("Setting key partition list... (this can take a minute if there are a lot of keys installed)") do
          # Strip keychain password from command output
          sensitive_command = command.gsub(password_part, " -k ********")
          UI.command(sensitive_command) if output
          Open3.popen3(command) do |stdin, stdout, stderr, thrd|
            unless thrd.value.success?
              err = stderr.read.to_s.strip

              # Inform user when no/wrong password was used as its needed to prevent UI permission popup from Xcode when signing
              if err.include?("SecKeychainItemSetAccessWithPassword")
                keychain_name = File.basename(keychain_path, ".*")
                Security::InternetPassword.delete(server: server_name(keychain_name))

                UI.important("")
                UI.important("Could not configure imported keychain item (certificate) to prevent UI permission popup when code signing\n" \
                         "Check if you supplied the correct `keychain_password` for keychain: `#{keychain_path}`\n" \
                         "#{err}")
                UI.important("")
                UI.important("Please look at the following docs to see how to set a keychain password:")
                UI.important(" - https://docs.fastlane.tools/actions/sync_code_signing")
                UI.important(" - https://docs.fastlane.tools/actions/get_certificates")
              else
                UI.error(err)
              end
            end
          end
        end

      end
    end

    # https://github.com/fastlane/fastlane/issues/14196
    # Keychain password is needed to set the partition list to
    # prevent Xcode from prompting dialog for keychain password when signing
    # 1. Uses keychain password from login keychain if found
    # 2. Prompts user for keychain password and stores it in login keychain for user later
    def self.resolve_keychain_password(keychain_path)
      keychain_name = File.basename(keychain_path, ".*")
      server = server_name(keychain_name)

      # Attempt to find password in keychain for keychain
      begin
        item = Security::InternetPassword.find(server: server)
      rescue Security::Error => ex
        UI.important("Could not read the keychain item #{server}: #{ex.message}")
        item = nil
      end

      if item
        keychain_password = item.password
        UI.important("Using keychain password from keychain item #{server} in #{keychain_path}")
      end

      if keychain_password.nil?
        if UI.interactive?
          UI.important("Enter the password for #{keychain_path}")
          UI.important("This passphrase will be stored in your local keychain with the name #{server} and used in future runs")
          UI.important("This prompt can be avoided by specifying the 'keychain_password' option or 'MATCH_KEYCHAIN_PASSWORD' environment variable")
          keychain_password = FastlaneCore::Helper.ask_password(message: "Password for #{keychain_name} keychain: ", confirm: true, confirmation_message: "Type password for #{keychain_name} keychain again: ")
          Security::InternetPassword.add(server, "", keychain_password)
        else
          UI.important("Keychain password for #{keychain_path} was not specified and not found in your keychain. Specify the 'keychain_password' option to prevent the UI permission popup when code signing")
          keychain_password = ""
        end
      end

      return keychain_password
    end

    # server name used for accessing the macOS keychain
    def self.server_name(keychain_name)
      ["fastlane", "keychain", keychain_name].join("_")
    end

    private_class_method :server_name
  end
end
