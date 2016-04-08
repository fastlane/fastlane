module Cert
  class KeychainImporter
    def self.import_file(path)
      UI.user_error!("Could not find file '#{path}'") unless File.exist?(path)
      keychain = File.expand_path(Cert.config[:keychain_path])

      command = "security import #{path.shellescape} -k '#{keychain}'"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"

      Helper.backticks(command)
    end
  end
end
