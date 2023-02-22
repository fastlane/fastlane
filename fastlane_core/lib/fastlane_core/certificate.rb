
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
        certs.sort_by { |c| c["NotAfter"] }.reverse! unless ascending
        certs.sort_by { |c| c["NotAfter"] }
      end

      def parse_from_b64(b64_content)
        serial_number = `echo #{b64_content} | base64 --decode | openssl x509 -inform der -noout -serial`.split("=").last.strip
        not_before = Time.parse(`echo #{b64_content} | base64 --decode | openssl x509 -inform der -noout -startdate`.split("=").last.strip)
        not_after = Time.parse(`echo #{b64_content} | base64 --decode | openssl x509 -inform der -noout -enddate`.split("=").last.strip)
        {
          "SerialNumber" => serial_number,
          "NotBefore" => not_before,
          "NotAfter" => not_after
        }
      end

      def parse_from_file(path)
        serial_number = `openssl x509 -inform der -noout -serial -in '#{path}'`.split("=").last.strip
        file_name = File.basename(path).gsub(".cer", "").gsub(".p12", "").gsub(".pem", "")
        not_before = Time.parse(`openssl x509 -inform der -noout -startdate -in '#{path}'`.split("=").last.strip)
        not_after = Time.parse(`openssl x509 -inform der -noout -enddate -in '#{path}'`.split("=").last.strip)
        {
            "SerialNumber" => serial_number,
            "FileName" => file_name,
            "NotBefore" => not_before,
            "NotAfter" => not_after
        }
      end
    end
  end
end
