module PEM
  class CertManager
    # Download the cert, do all kinds of Keychain related things
    def run
      # Keychain (security) documentation: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/security.1.html
      # Old project, which might be helpful: https://github.com/jprichardson/keychain_manager

      Helper.log.info "Refreshing push notification profiles for app '#{PEM.config[:app_identifier]}'"

      dev = PEM::DeveloperCenter.new

      cert_file = dev.fetch_cer_file
      rsa_file = File.join(TMP_FOLDER, 'private_key.key')

      pem_temp = File.join(TMP_FOLDER, 'pem_temp.pem')

      certificate_type = (PEM.config[:development] ? 'development' : 'production')


      pem_file = File.join(TMP_FOLDER, "#{certificate_type}_#{PEM.config[:app_identifier]}.pem")
      command("openssl x509 -inform der -in '#{cert_file}' -out #{pem_temp}")
      content = File.read(pem_temp) + File.read(rsa_file)
      File.write(pem_file, content)

      # Generate p12 file as well
      if PEM.config[:generate_p12]
        output = "#{certificate_type}.p12"
        command("openssl pkcs12 -export -password pass:"" -in '#{pem_file}' -inkey '#{pem_file}' -out '#{output}'")
        puts output.green
      end
      
      return pem_file, rsa_file
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