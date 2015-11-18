module Cert
  class KeychainImporter
    def self.import_file(path)
      raise "Could not find file '#{path}'".red unless File.exist?(path)
      keychain = File.expand_path(Cert.config[:keychain_path] || "#{Dir.home}/Library/Keychains/login.keychain")

      command = "security import #{path.shellescape} -k '#{keychain}'"
      command << " -T /usr/bin/codesign" # to not be asked for permission when running a tool like `gym`
      command << " -T /usr/bin/security"
      Helper.log.info command.yellow
      Helper.log.info `#{command}`
    end
  end
end
