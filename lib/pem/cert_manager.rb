module PEM
  class CertManager
    # Download the cert, do all kinds of Keychain related things
    def run(app_identifier, production)
      # Keychain (security) documentation: https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/security.1.html
      # Old project, which might be helpful: https://github.com/jprichardson/keychain_manager

      Helper.log.info "Refreshing push notification profiles for app '#{app_identifier}'"

      dev = FastlaneCore::DeveloperCenter.new

      cert_file = dev.fetch_cer_file(app_identifier, production)
      rsa_file = File.join(TMP_FOLDER, 'private_key.key')

      pem_temp = File.join(TMP_FOLDER, 'pem_temp.pem')

      certificate_type = (production ? 'production' : 'development')


      pem_file = File.join(TMP_FOLDER, "#{certificate_type}_#{app_identifier}.pem")
      command("openssl x509 -inform der -in '#{cert_file}' -out #{pem_temp}")
      content = File.read(pem_temp) + File.read(rsa_file)
      File.write(pem_file, content)
      

      File.delete(rsa_file)

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