module Fastlane
  module Actions
    module SharedValues
    end

    class UpdatePlistAction < Action
      # Wrapper class that converts symbol keys to strings when accessing hash
      # This allows users to use symbols like plist[:KEY] while maintaining
      # compatibility with the string keys returned by Xcodeproj::Plist
      class PlistHashWrapper
        def initialize(hash)
          @hash = hash
        end

        def []=(key, value)
          @hash[key.to_s] = value
        end

        def [](key)
          @hash[key.to_s]
        end

        def fetch(key, *args, &block)
          @hash.fetch(key.to_s, *args, &block)
        end

        def key?(key)
          @hash.key?(key.to_s)
        end

        def has_key?(key)
          @hash.has_key?(key.to_s)
        end

        def delete(key)
          @hash.delete(key.to_s)
        end

        # Delegate all other methods to the underlying hash
        def method_missing(method, *args, &block)
          @hash.send(method, *args, &block)
        end

        def respond_to_missing?(method, include_private = false)
          @hash.respond_to?(method, include_private) || super
        end
      end
      def self.run(params)
        require 'xcodeproj'

        if params[:plist_path].nil?
          UI.user_error!("You must specify a plist path")
        end

        # Read existing plist file
        plist_path = params[:plist_path]

        UI.user_error!("Couldn't find plist file at path '#{plist_path}'") unless File.exist?(plist_path)
        plist = Xcodeproj::Plist.read_from_path(plist_path)

        # Wrap the plist hash to automatically convert symbol keys to strings
        wrapped_plist = PlistHashWrapper.new(plist)
        params[:block].call(wrapped_plist) if params[:block]

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
        "This action allows you to modify any value inside any `plist` file."
      end

      def self.available_options
        [

          FastlaneCore::ConfigItem.new(key: :plist_path,
                                       env_name: "FL_UPDATE_PLIST_PATH",
                                       description: "Path to plist file",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :block,
                                       type: :string_callback,
                                       description: 'A block to process plist with custom logic')

        ]
      end

      def self.author
        ["rishabhtayal", "matthiaszarzecki"]
      end

      def self.example_code
        [
          'update_plist( # Updates the CLIENT_ID and GOOGLE_APP_ID string entries in the plist-file
            plist_path: "path/to/your_plist_file.plist",
            block: proc do |plist|
              plist[:CLIENT_ID] = "new_client_id"
              plist[:GOOGLE_APP_ID] = "new_google_app_id"
            end
          )',
          'update_plist( # Sets a boolean entry
            plist_path: "path/to/your_plist_file.plist",
            block: proc do |plist|
              plist[:boolean_entry] = true
            end
          )',
          'update_plist( # Sets a number entry
            plist_path: "path/to/your_plist_file.plist",
            block: proc do |plist|
              plist[:number_entry] = 13
            end
          )',
          'update_plist( # Sets an array-entry with multiple sub-types
            plist_path: "path/to/your_plist_file.plist",
            block: proc do |plist|
              plist[:array_entry] = ["entry_01", true, 1243]
            end
          )',
          'update_plist( # The block can contain logic too
            plist_path: "path/to/your_plist_file.plist",
            block: proc do |plist|
              if options[:environment] == "production"
                plist[:CLIENT_ID] = "new_client_id_production"
              else
                plist[:CLIENT_ID] = "new_client_id_development"
              end
            end
          )',
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
