module FastlaneCore
  class KeychainImporter
    def self.import_file(path, keychain_path, certificate_password: nil, output: false)
      UI.user_error!("Could not find file '#{path}'") unless File.exist?(path)

      command = "security import #{path.shellescape} -k '#{keychain_path.shellescape}'"
      command << " -P #{certificate_password.shellescape}" if certificate_password
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      command << " &> /dev/null" unless output

      Helper.backticks(command, print: output)
    end
  end
end
