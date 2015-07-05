module FastlaneCore
  # This class checks if a specific certificate is installed on the current mac
  class CertChecker
    def self.is_installed?(path)
      raise "Could not find file '#{path}'".red unless File.exists?(path)

      ids = installed_identies
      finger_print = sha1_fingerprint(path)

      return ids.include?finger_print
    end

    def self.installed_identies
      available = `security find-identity -v -p codesigning`
      ids = []
      available.split("\n").each do |current|
        unless current.include?"REVOKED"
          (ids << current.match(/.*\) (.*) \".*/)[1]) rescue nil # the last line does not match
        end
      end

      return ids
    end

    def self.sha1_fingerprint(path)
      result = `openssl x509 -in "#{path}" -inform der -noout -sha1 -fingerprint`
      begin
        result = result.match(/SHA1 Fingerprint=(.*)/)[1]
        result.gsub!(":", "")
        return result
      rescue => ex
        Helper.log.info result
        raise "Error parsing certificate '#{path}'"
      end
    end
  end
end