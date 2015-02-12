module Cert
  class KeychainImporter
    def self.import_file(path)
      raise "Could not find file '#{path}'".red unless File.exists?(path)
      keychain = ENV["CERT_KEYCHAIN_PATH"] || "#{Dir.home}/Library/Keychains/login.keychain"
      
      puts `security import '#{path}' -k '#{keychain}'`
    end
  end
end