module Fastlane
  module Actions
    module SharedValues
    end

    class UploadToAmazonAppstoreAction < Action
      require_relative '../helper.rb'
      require_relative '../client.rb'

      def self.run(params)
        app_id = params[:app_id]
        replace_apk_id = params[:replace_apk_id]

        client = ActionSets::Amazon::Client.new
        client.authenticate_if_needed

        # Establish current or new edit
        edit = instance.get_active_edit(app_id: params[:app_id])
        if edit.nil?
          edit = instance.create_edit(app_id: app_id)
        elsif edit.status != 'IN_PROGRESS'
          UI.error!("Active edit must be 'IN_PROGRESS'; instead, it is '#{edit.status}'.")
        end
        edit_id = edit.id

        # Get a list of APKs and find our specific APK, or use the first one
        apks = instance.get_apks(edit_id: edit_id, app_id: app_id)
        if apks.empty?
          UI.error!('Did not find any APKs to replace.')
        elsif apks.length > 1 && !replace_apk_id
          apk_ids = apks.map(&:id)
          UI.user_error!("Found >1 replaceable APKs; pass one of #{apk_ids.join(',')} into apk_id=")
        end
        apk_id = apks[0].id
        if replace_apk_id
          apk = apks.find { |a| a.id == replace_apk_id }
          UI.user_error!("Unable to find APK with id match #{replace_apk_id}") unless apk
          apk_id = apk.id
        end

        # Cache the ETag for this APK, and then use the ETag to replace the APK
        apk_metadata = instance.get_apk(apk_id, edit_id: edit_id, app_id: app_id)
        instance.replace_apk(
          apk_metadata.id,
          apk_filepath: params[:apk],
          edit_id: edit_id,
          app_id: app_id
        )
        UI.message("Successfully created new version and replaced APK #{apk_id}.")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload to Amazon Appstore"
      end

      def self.details
        "Upload to Amazon Appstore"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :apk,
                                        env_name: "AMAZON_APK",
                                        description: "Path to the APK file to upload",
                                        code_gen_sensitive: true,
                                        default_value: Dir["*.apk"].last || Dir[File.join("app", "build", "outputs", "apk", "app-Release.apk")].last,
                                        default_value_dynamic: true,
                                        optional: true,
                                        verify_block: proc do |value|
                                          UI.user_error!("Could not find apk file at path '#{value}'") unless File.exist?(value)
                                          UI.user_error!("apk file is not an apk") unless value.end_with?('.apk')
                                        end),
          FastlaneCore::ConfigItem.new(key: :app_id,
                                        env_name: "AMAZON_APP_ID",
                                        description: "The Amazon Appstore ID for your app",
                                        optional: false),
          FastlaneCore::ConfigItem.new(key: :replace_apk_id,
                                        env_name: "AMAZON_REPLACE_APK_ID",
                                        description: "The ID of the APK you wish to replace, if applicable",
                                        optional: true)
        ]
      end

      def self.output
      end

      def self.category
        :production
      end

      def self.example_code
        [
          'upload_to_amazon_appstore(
            apk: "path",
            app_id: "amzn1.devportal.mobileapp.ABC123"
          )'
        ]
      end

      def self.authors
        ["kreeger", "joshdholtz"]
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
