module Cert
  class KeychainImporter
    def self.import_file(path)
      raise "Could not find file '#{path}'".red unless File.exist?(path)
      keychain = File.expand_path(Cert.config[:keychain_path]) || "#{Dir.home}/Library/Keychains/login.keychain"

      puts `security import '#{path}' -k '#{keychain}' -T /usr/bin/codesign`
    end
  end
end
