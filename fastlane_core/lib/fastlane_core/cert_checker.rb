module FastlaneCore
  # This class checks if a specific certificate is installed on the current mac
  class CertChecker
    def self.installed?(path)
      raise "Could not find file '#{path}'".red unless File.exist?(path)

      ids = installed_identies
      finger_print = sha1_fingerprint(path)

      return ids.include? finger_print
    end

    # Legacy Method, use `installed?` instead
    def self.is_installed?(path)
      installed?(path)
    end

    def self.installed_identies
      install_wwdr_certificate unless wwdr_certificate_installed?

      available = `security find-identity -v -p codesigning`
      if available.include?("0 valid identities found")
        UI.error("Looks like there are no local code signing identities found, you can run `security find-identity -v -p codesigning` to get this output. Check out this reply for more: https://stackoverflow.com/questions/35390072/this-certificate-has-an-invalid-issuer-apple-push-services")
      end

      ids = []
      available.split("\n").each do |current|
        next if current.include? "REVOKED"
        begin
          (ids << current.match(/.*\) (.*) \".*/)[1])
        rescue
          # the last line does not match
        end
      end

      return ids
    end

    def self.wwdr_certificate_installed?
      certificate_name = "Apple Worldwide Developer Relations Certification Authority"
      response = Helper.backticks("security find-certificate -c '#{certificate_name}'", print: $verbose)
      return response.include?("attributes:")
    end

    def self.install_wwdr_certificate
      Dir.chdir('/tmp') do
        url = 'https://developer.apple.com/certificationauthority/AppleWWDRCA.cer'
        filename = File.basename(url)
        `curl -O #{url} && security import #{filename} -k login.keychain`
        UI.user_error!("Could not install WWDR certificate") unless $?.success?
      end
    end

    def self.sha1_fingerprint(path)
      result = `openssl x509 -in "#{path}" -inform der -noout -sha1 -fingerprint`
      begin
        result = result.match(/SHA1 Fingerprint=(.*)/)[1]
        result.delete!(':')
        return result
      rescue
        Helper.log.info result
        raise "Error parsing certificate '#{path}'"
      end
    end
  end
end
