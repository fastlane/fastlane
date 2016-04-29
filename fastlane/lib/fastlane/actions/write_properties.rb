module Fastlane
  module Actions
    class WritePropertiesAction < Action
      def self.run(params)
        properties = params[:properties]
        path = params[:path]

        file = File.new(path, "w")
        properties.each { |key, value| file.puts "#{key}=#{value}\n" }
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Write to a Java properties file"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_WRITE_PROPERTIES_PATH",
                                       description: "path to write properties file to"),
          FastlaneCore::ConfigItem.new(key: :properties,
                                       env_name: "FL_WRITE_PROPERTIES_PROPERTIES",
                                       description: "hash of properties to write in the properties file format",
                                       is_string: false,
                                       verify_block: proc do |value|
                                         UI.user_error!("Properties must be a Hash, not #{value.class}") unless value.kind_of?(Hash)
                                       end)
        ]
      end

      def self.authors
        ["Ashton-W"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
