require_relative 'helper'
require 'open3'
require 'security'

module FastlaneCore
  class KeychainImporter
    def self.import_file(path, keychain_path, keychain_password: nil, certificate_password: "", skip_set_partition_list: false, output: FastlaneCore::Globals.verbose?)
      UI.user_error!("Could not find file '#{path}'") unless File.exist?(path)

      password_part = " -P #{certificate_password.shellescape}"

      command = "security import #{path.shellescape} -k '#{keychain_path.shellescape}'"
      command << password_part
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym` (before Sierra)
      command << " -T /usr/bin/security"
      command << " -T /usr/bin/productbuild" # to not be asked for permission when using an installer cert for macOS
      command << " -T /usr/bin/productsign"  # to not be asked for permission when using an installer cert for macOS
      command << " 1> /dev/null" unless output

      sensitive_command = command.gsub(password_part, " -P ********")
      UI.command(sensitive_command) if output
      Open3.popen3(command) do |stdin, stdout, stderr, thrd|
        UI.command_output(stdout.read.to_s) if output

        # Set partition list only if success since it can be a time consuming process if a lot of keys are installed
        if thrd.value.success? && !skip_set_partition_list
          keychain_password ||= resolve_keychain_password(keychain_path)
          set_partition_list(path, keychain_path, keychain_password: keychain_password, output: output)
        else
          # Output verbose if file is already installed since not an error otherwise we will show the whole error
          err = stderr.read.to_s.strip
          if err.include?("SecKeychainItemImport") && err.include?("The specified item already exists in the keychain")
            UI.verbose("'#{File.basename(path)}' is already installed on this machine")
          else
            UI.error(err)
          end
        end
      end
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
        Helper.show_loading_indicator("Setting key partition list... (this can take a minute if there are a lot of keys installed)")

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

        # Hiding after Open3 finishes
        Helper.hide_loading_indicator

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
      item = Security::InternetPassword.find(server: server)
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
