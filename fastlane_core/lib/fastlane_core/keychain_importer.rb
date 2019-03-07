require_relative 'helper'
require 'open3'

module FastlaneCore
  class KeychainImporter
    def self.import_file(path, keychain_path, keychain_password: "", certificate_password: "", output: FastlaneCore::Globals.verbose?)
      UI.user_error!("Could not find file '#{path}'") unless File.exist?(path)

      command = "security import #{path.shellescape} -k '#{keychain_path.shellescape}'"
      command << " -P #{certificate_password.shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym` (before Sierra)
      command << " -T /usr/bin/security"
      command << " 1> /dev/null" unless output

      UI.command(command) if output
      Open3.popen3(command) do |stdin, stdout, stderr, thrd|
        UI.command_output(stdout.read.to_s) if output

        # Set partition list only if success since it can be a time consuming process if a lot of keys are installed
        if thrd.value.success?
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

    def self.set_partition_list(path, keychain_path, keychain_password: "", output: FastlaneCore::Globals.verbose?)
      # When security supports partition lists, also add the partition IDs
      # See https://openradar.appspot.com/28524119
      if Helper.backticks('security -h | grep set-key-partition-list', print: false).length > 0
        command = "security set-key-partition-list"
        command << " -S apple-tool:,apple:"
        command << " -k #{keychain_password.to_s.shellescape}"
        command << " #{keychain_path.shellescape}"
        command << " 1> /dev/null" # always disable stdout. This can be very verbose, and leak potentially sensitive info

        # Showing loading indicator as this can take some time if a lot of keys installed
        Helper.show_loading_indicator("Setting key partition list... (this can take a minute if there are a lot of keys installed)")

        UI.command(command) if output
        Open3.popen3(command) do |stdin, stdout, stderr, thrd|
          unless thrd.value.success?
            err = stderr.read.to_s.strip

            # Inform user when no/wrong password was used as its needed to prevent UI permission popup from Xcode when signing
            if err.include?("SecKeychainItemSetAccessWithPassword")
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
  end
end
