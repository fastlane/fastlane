require 'plist'

module Fastlane
  module Actions
    class UpdateUrlSchemesAction < Action
      def self.run(params)
        path = params[:path]
        url_schemes = params[:url_schemes]
        update_url_schemes = params[:update_url_schemes]

        hash = Plist.parse_xml(path)

        # Create CFBundleURLTypes array with empty scheme if none exist
        unless hash['CFBundleURLTypes']
          hash['CFBundleURLTypes'] = [{
            'CFBundleTypeRole' => 'Editor',
            'CFBundleURLSchemes' => []
          }]
        end

        # Updates schemes with update block if exists
        # Else updates with array of strings if exist
        # Otherwise shows error to user
        if update_url_schemes
          new_schemes = update_url_schemes.call(hash['CFBundleURLTypes'].first['CFBundleURLSchemes'])

          # Verify array of strings
          string = "The URL schemes must be an array of strings, got '#{new_schemes}'."
          verify_schemes!(new_schemes, string)

          hash['CFBundleURLTypes'].first['CFBundleURLSchemes'] = new_schemes
        elsif url_schemes
          hash['CFBundleURLTypes'].first['CFBundleURLSchemes'] = url_schemes
        else
          UI.user_error!("No `url_schemes` or `update_url_schemes` provided")
        end
        File.write(path, Plist::Emit.dump(hash))
      end

      def self.verify_schemes!(url_schemes, error_message)
        UI.user_error!(error_message) unless url_schemes.kind_of?(Array)

        url_schemes.each do |url_scheme|
          UI.user_error!(error_message) unless url_scheme.kind_of?(String)
        end
      end

      def self.description
        'Updates the URL schemes in the given Info.plist'
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: 'FL_UPDATE_URL_SCHEMES_PATH',
                                       description: 'The Plist file\'s path',
                                       optional: false,
                                       verify_block: proc do |path|
                                         UI.user_error!("Could not find plist at path '#{path}'") unless File.exist?(path)
                                       end),
          FastlaneCore::ConfigItem.new(key: :url_schemes,
                                       env_name: "FL_UPDATE_URL_SCHEMES_SCHEMES",
                                       description: 'The new URL schemes',
                                       type: Array,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :update_url_schemes,
                                       description: "Block that is called to update schemes with current schemes passed in as parameter",
                                       optional: true,
                                       type: :string_callback)
        ]
      end

      def self.details
        [
          "This action allows you to update the URL schemes of the app before building it.",
          "For example, you can use this to set a different URL scheme for the alpha or beta version of the app."
        ].join("\n")
      end

      def self.output
        []
      end

      def self.authors
        ['kmikael']
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.example_code
        [
          'update_url_schemes(
            path: "path/to/Info.plist",
            url_schemes: ["com.myapp"]
          )',
          'update_url_schemes(
            path: "path/to/Info.plist",
            update_url_schemes: proc do |schemes|
              schemes + ["anotherscheme"]
            end
          )'
        ]
      end

      def self.category
        :project
      end
    end
  end
end
