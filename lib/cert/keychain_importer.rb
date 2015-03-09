module Cert
  class KeychainImporter
    def self.import_file(path)
      raise "Could not find file '#{path}'".red unless File.exists?(path)
      keychain = Cert.config[:keychain_path] || "#{Dir.home}/Library/Keychains/login.keychain"
      
      puts `security import '#{path}' -k '#{keychain}'`
    end
  end
end