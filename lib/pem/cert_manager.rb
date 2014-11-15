module PEM
  class CertManager
    # Download the cert, do all kinds of Keychain related things
    def run(app_identifier)
      # Keychain (security) documentation: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/security.1.html
      # Old project, which might be helpful: https://github.com/jprichardson/keychain_manager

      Helper.log.info "Refreshing push notification profiles for app '#{app_identifier}'"

      dev = PEM::DeveloperCenter.new

      keychain = "PEM.keychain"

      cert_file = dev.fetch_cer_file(app_identifier)
      rsa_file = [TMP_FOLDER, 'myrsa'].join('/')

      previous_keychain = command("security default-keychain")



      command("security create-keychain -p '' #{keychain}") # create a new keychain for this type

      command("security list-keychains -d user -s #{keychain}") # add it to the list of keychains

      command("openssl genrsa -out '#{rsa_file}' 2048") # generate a new RSA file
      command("security import '#{rsa_file}' -P '' -k #{keychain}") # import the RSA file into the Keychain
      command("security import '#{cert_file}' -k #{keychain}") # import the profile from Apple into the Keychain

      p12_file = [TMP_FOLDER, "push_prod.12"].join('/')

      command("security export -k '#{keychain}' -t all -f pkcs12 -P '' -o #{p12_file}") # export code signing identity

      pem_file = [TMP_FOLDER, "production_#{app_identifier}.pem"].join('')
      command("openssl pkcs12 -passin pass: -nodes -in #{p12_file} -out #{pem_file}")

      command("security delete-keychain #{keychain}")

      command("security list-keychains -d user -s #{previous_keychain}") # switch back to default keychain

      return pem_file
    end

    private
      # Output the command, execute it, return its result
      def command(com)
        puts com.yellow
        result = `#{com}`
        puts result if (result || '').length > 0
        result
      end
  end
end