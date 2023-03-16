
module FastlaneCore
  class Certificate
    class << self
      # @return (Hash) The hash with the data of the certificate
      # @example
      #  {"SerialNumber"=>"069FBA785158DC46D9A6603EAF5A1316"
      #  "FileName"=>"certificate-13",
      #  "NotAfter"=>"Feb 21 16:39:53 2024 GMT",
      #  "NotBefore"=>"Feb 21 16:39:53 2023 GMT"}
      def order_by_expiration(certs, ascending = true)
        certs.sort_by { |c| c["NotAfter"].to_i }.reverse! unless ascending
        certs.sort_by { |c| c["NotAfter"].to_i }
      end

      def parse_from_b64(b64_content)
        openssl_object = OpenSSL::X509::Certificate.new(Base64.decode64(b64_content))
        {
          "SerialNumber" => openssl_object.serial.to_s(16).upcase,
          "NotBefore" => openssl_object.not_before,
          "NotAfter" => openssl_object.not_after
        }
      end

      def parse_from_file(path)
        file_name = File.basename(path).gsub(".cer", "").gsub(".p12", "").gsub(".pem", "")
        openssl_object = OpenSSL::X509::Certificate.new(File.read(path))
        {
            "SerialNumber" => openssl_object.serial.to_s(16).upcase,
            "FileName" => file_name,
            "NotBefore" => openssl_object.not_before,
            "NotAfter" => openssl_object.not_after
        }
      end
    end
  end
end
