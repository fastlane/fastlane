require 'plist'

module Fastlane
  module Actions
    class UpdateUrlSchemesAction < Action
      def self.run(params)
        path = params[:path]
        url_schemes = params[:url_schemes]

        hash = Plist.parse_xml(path)
        hash['CFBundleURLTypes'].first['CFBundleURLSchemes'] = url_schemes
        File.write(path, hash.to_plist)
      end

      def self.description
        'Updates the URL schemes in the given Info.plist'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :path,
            env_name: 'FL_UPDATE_URL_SCHEMES_PATH',
            description: 'The Plist file\'s path',
            is_string: true,
            optional: false,
            verify_block: proc do |path|
              raise "Could not find plist at path '#{path}'".red unless File.exist?(path)
            end
          ),

          FastlaneCore::ConfigItem.new(
            key: :url_schemes,
            env_name: "FL_UPDATE_URL_SCHEMES_SCHEMES",
            description: 'The new URL schemes',
            is_string: false,
            optional: false,
            verify_block: proc do |url_schemes|
              string = "The URL schemes must be an array of strings, got '#{url_schemes}'.".red
              raise string unless url_schemes.kind_of?(Array)

              url_schemes.each do |url_scheme|
                raise string unless url_scheme.kind_of?(String)
              end
            end
          )
        ]
      end

      def self.output
        []
      end

      def self.authors
        ['kmikael']
      end

      def self.is_supported?(platform)
        [:ios, :mac].include? platform
      end
    end
  end
end
