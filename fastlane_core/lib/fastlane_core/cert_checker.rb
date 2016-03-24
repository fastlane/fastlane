module FastlaneCore
  # This class checks if a specific certificate is installed on the current mac
  class CertChecker
    def self.installed?(path, keychain = nil)
      raise "Could not find file '#{path}'".red unless File.exist?(path)

      ids = installed_identies( keychain )
      finger_print = sha1_fingerprint(path)

      return ids.include? finger_print
    end

    # Legacy Method, use `installed?` instead
    def self.is_installed?(path)
      installed?(path)
    end

    def self.installed_identies( keychain = nil )
      install_wwdr_certificate unless wwdr_certificate_installed?( keychain )

      available = list_available_identities( keychain )
      # Match for this text against word boundaries to avoid edge cases around multiples of 10 identities!
      if /\b0 valid identities found\b/ =~ available
        UI.error([
          "There are no local code signing identities found.",
          "You can run `security find-identity -v -p codesigning` to get this output.",
          "This Stack Overflow thread has more information: http://stackoverflow.com/q/35390072/774.",
          "(Check in Keychain Access for an expired WWDR certificate: http://stackoverflow.com/a/35409835/774 has more info.)"
        ].join(' '))
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

    def self.list_available_identities( keychain = nil )
      `security find-identity -v -p codesigning #{keychain.to_s}`
    end

    def self.wwdr_certificate_installed?( keychain )
      certificate_name = "Apple Worldwide Developer Relations Certification Authority"
      response = Helper.backticks("security find-certificate -c '#{certificate_name}' #{keychain}", print: $verbose)
      return response.include?("attributes:")
    end

    def self.install_wwdr_certificate( keychain = nil )
      Dir.chdir('/tmp') do
        url = 'https://developer.apple.com/certificationauthority/AppleWWDRCA.cer'
        filename = File.basename(url)
        `curl -O #{url} && security import #{filename} -k #{keychain || 'login.keychain'}`
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
