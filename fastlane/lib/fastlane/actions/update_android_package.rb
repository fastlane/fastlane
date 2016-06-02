module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateAndroidPackageAction < Action
      def self.run(params)
        require 'nokogiri'
        ## Check if parameters are set
        if params[:app_identifier] or params[:display_name]
          if params[:display_name]
            manifest_path = File.join(".", params[:manifest_path])
            string_resource_path = File.join(".", params[:string_resource_path])
            UI.user_error!("Couldn't find manifest file at path '#{params[:manifest_path]}'") unless File.exist?(manifest_path)
            UI.user_error!("Couldn't find string resource file at path '#{params[:string_resource_path]}'") unless File.exist?(string_resource_path)

            ## Parse XML
            manifest = Nokogiri::XML(File.open(manifest_path))
            strings = Nokogiri::XML(File.open(string_resource_path))

            ## Change name
            # Find all activities inside the app
            activites = manifest.xpath("//application//activity")
            activites.each do |activity|
              activity_node = Nokogiri::XML(activity.to_s)
              # Find launcher activity
              if activity_node.at_css("intent-filter").to_s != ""
                intent_filter_node = Nokogiri::XML(activity_node.at_css("intent-filter").to_s)
                if intent_filter_node.at_css("action").to_s != "" && intent_filter_node.at_css("category").to_s != ""
                  if intent_filter_node.at_css("action").attributes["android:name"].value == "android.intent.action.MAIN" && \
                    intent_filter_node.at_css("category").attributes["android:name"].value == "android.intent.category.LAUNCHER"
                    # Update manifest values
                    if activity.attributes["label"].value.start_with? "@string"
                      # If label is getting from strings.xml, change in strings.xml
                      string_resource_name = activity.attributes["label"].value.sub("@string/","")
                      app_name_resource = strings.search('string[name="' + string_resource_name + '"]')
                      app_name_resource[0].content = params[:display_name]
                      File.write(string_resource_path, strings.to_xml)
                    else
                      # If label is manually put in the attribute, change the attribute directly
                      activity.attributes["label"].value = params[:display_name]
                      File.write(manifest_path, manifest.to_xml)
                    end
                  end
                end
              end
            end
            UI.success("Updated #{params[:manifest_path]} 💾.")
          end

          ## Change app identifier
          if params[:app_identifier]
            app_build_gradle_path = File.join(".", params[:app_build_gradle_path])
            UI.user_error!("Couldn't find build.gradle file at path '#{params[:app_build_gradle_path]}'") unless File.exist?(app_build_gradle_path)
            build_gradle = File.open(app_build_gradle_path).read
            build_gradle = build_gradle.sub(/applicationId\s"(.+)"/.match(build_gradle)[1], params[:app_identifier])
            File.write(app_build_gradle_path, build_gradle)

          end

        else
          UI.important("You haven't specified any parameters to update your package.")
          false
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Update a Android packaging files with new information'
      end

      def self.details
        "This action allows you to modify your AndroidManifest.xml and build.gradle file before building. This may be useful if you want a separate build for alpha, beta or nightly builds, but don't want a separate target."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :manifest_path,
                                       env_name: "FL_UPDATE_ANDROID_MANIFEST_PATH",
                                       description: "Path to AndroidManifest.xml",
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid manifest file") unless value.end_with? "AndroidManifest.xml"
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_build_gradle_path,
                                       env_name: "FL_UPDATE_ANDROID_BUILD_GRADLE_PATH",
                                       description: "Path to app/build.gradle",
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid build.gradle file") unless value.end_with? "build.gradle"
                                       end),
          FastlaneCore::ConfigItem.new(key: :string_resource_path,
                                       env_name: "FL_UPDATE_ANDROID_MANIFEST_STRING_RESOURCE_PATH",
                                       description: "Path to res/values/strings.xml",
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid string resource path") unless value.end_with? "strings.xml"
                                       end),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       env_name: 'FL_UPDATE_ANDROID_MANIFEST_APP_IDENTIFIER',
                                       description: 'The bundle identifier or application ID of your app',
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :display_name,
                                       env_name: 'FL_UPDATE_ANDROID_MANIFEST_DISPLAY_NAME',
                                       description: 'The Display Name of your app',
                                       optional: true),

        ]
      end

      def self.authors
        "ncnlinh"
      end

      def self.is_supported?(platform)
        platform == :android
      end
    end
  end
end
