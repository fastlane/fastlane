module Fastlane
  module Actions
    module SharedValues
      DOWNLOAD_CONTENT = :DOWNLOAD_CONTENT
    end

    class DownloadAction < Action
      def self.run(params)
        require 'net/http'

        begin
          result = Net::HTTP.get(URI(params[:url]))
          begin
            result = JSON.parse(result) # try to parse and see if it's valid JSON data
          rescue
            # never mind, using standard text data instead
          end
          Actions.lane_context[SharedValues::DOWNLOAD_CONTENT] = result
        rescue => ex
          UI.user_error!("Error fetching remote file: #{ex}")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Download a file from a remote server (e.g. JSON file)"
      end

      def self.details
        [
          "Specify the URL to download and get the content as a return value.",
          "Automatically parses JSON into a Ruby data structure.",
          "For more advanced networking code, use the Ruby functions instead: [http://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html](http://docs.ruby-lang.org/en/2.0.0/Net/HTTP.html)."
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :url,
                                       env_name: "FL_DOWNLOAD_URL",
                                       description: "The URL that should be downloaded",
                                       verify_block: proc do |value|
                                         UI.important("The URL doesn't start with http or https") unless value.start_with?("http")
                                       end)
        ]
      end

      def self.output
        [
          ['DOWNLOAD_CONTENT', 'The content of the file we just downloaded']
        ]
      end

      def self.example_code
        [
          'data = download(url: "https://host.com/api.json")'
        ]
      end

      def self.category
        :misc
      end

      def self.authors
        ["KrauseFx"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
