module Fastlane
  module Actions
    module SharedValues
    end

    class UpdatePlistAction < Action
      def self.run(params)
        require 'xcodeproj'

        if params[:plist_path].nil?
          UI.user_error!("You must specify a plist path")
        end

        # Read existing plist file
        plist_path = params[:plist_path]

        UI.user_error!("Couldn't find plist file at path '#{plist_path}'") unless File.exist?(plist_path)
        plist = Xcodeproj::Plist.read_from_path(plist_path)

        params[:block].call(plist) if params[:block]

        # Write changes to file
        Xcodeproj::Plist.write_to_path(plist, plist_path)

        UI.success("Updated #{params[:plist_path]} 💾.")
        File.read(plist_path)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end

      def self.description
        'Update a plist file'
      end

      def self.details
        "This action allows you to modify any `plist` file."
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_UPDATE_PLIST_PATH",
                                       description: "Path to plist file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :block,
                                       is_string: false,
                                       description: 'A block to process plist with custom logic')

        ]
      end

      def self.author
        'rishabhtayal'
      end

      def self.example_code
        [
          'update_plist( # Advanced processing: find URL scheme for particular key and replace value
            plist_path: "path/to/Info.plist",
            block: proc do |plist|
              urlScheme = plist["CFBundleURLTypes"].find{|scheme| scheme["CFBundleURLName"] == "com.acme.default-url-handler"}
              urlScheme[:CFBundleURLSchemes] = ["acme-production"]
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
