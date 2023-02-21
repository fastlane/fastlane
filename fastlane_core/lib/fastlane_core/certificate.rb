
module FastlaneCore
  class Certificate
    class << self
      # @return (Hash) The hash with the data of the certificate
      # @example
      #  {"SerialNumber"=>"069FBA785158DC46D9A6603EAF5A1316"
      #  "FileName"=>"Felix Krause",}
      def parse_from_file(path)
        serial_result = `openssl x509 -inform der -noout -serial -in '#{path}'`
        serial_number = serial_result.split("=").last.strip
        {
            "SerialNumber" => serial_number,
            "FileName" => File.basename(path).gsub(".cer", "").gsub(".p12", "").gsub(".pem", "")
        }
      end
    end
  end
end
