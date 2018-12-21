require_relative 'helper'
require 'open3'

module FastlaneCore
  class KeychainImporter
    def self.import_file(path, keychain_path, keychain_password: "", certificate_password: "", output: FastlaneCore::Globals.verbose?)
      UI.user_error!("Could not find file '#{path}'") unless File.exist?(path)

      command = "security import #{path.shellescape} -k '#{keychain_path.shellescape}'"
      command << " -P #{certificate_password.shellescape}"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      command << " &> /dev/null" unless output

      Helper.backticks(command, print: output)

      # When security supports partition lists, also add the partition IDs
      # See https://openradar.appspot.com/28524119
      if Helper.backticks('security -h | grep set-key-partition-list', print: false).length > 0
        command = "security set-key-partition-list"
        command << " -S apple-tool:,apple:"
        command << " -l 'Imported Private Key'"
        command << " -k #{keychain_password.to_s.shellescape}"
        command << " #{keychain_path.shellescape}"
        command << " 1> /dev/null" # always disable stdout. This can be very verbose, and leak potentially sensitive info

        UI.command(command) if output
        Open3.popen3(command) do |stdin, stdout, stderr, thrd|
          unless thrd.value.success?
            UI.user_error!("Could not configure key to bypass permission popup.\n" \
                           "Check if you supplied the correct `keychain_password` for keychain: `#{keychain_path}`\n" \
                           "#{stderr.read}")
          end
        end
      end
    end
  end
end
