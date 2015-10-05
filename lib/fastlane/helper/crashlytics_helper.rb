module Fastlane
  module Helper
    class CrashlyticsHelper
      class << self
        def generate_ios_command(params)
          command = []
          command << File.join(params[:crashlytics_path], 'submit')
          command << params[:api_token]
          command << params[:build_secret]
          command << "-ipaPath '#{params[:ipa_path]}'"
          command << "-emails '#{params[:emails]}'" if params[:emails]
          command << "-notesPath '#{params[:notes_path]}'" if params[:notes_path]
          command << "-groupAliases '#{params[:groups]}'" if params[:groups]
          command << "-notifications #{(params[:notifications] ? 'YES' : 'NO')}"

          return command
        end

        def generate_android_command(params)
          # We have to generate an empty XML file to make the crashlytics CLI happy :)
          require 'tempfile'

          xml = Tempfile.new('xml')
          xml.write('<?xml version="1.0" encoding="utf-8"?><manifest></manifest>')
          xml.close

          command = ["java"]
          command << "-jar #{File.expand_path(params[:crashlytics_path])}"
          command << "-androidRes ."
          command << "-apiKey #{params[:api_token]}"
          command << "-apiSecret #{params[:build_secret]}"
          command << "-uploadDist '#{File.expand_path(params[:apk_path])}'"
          command << "-androidManifest '#{xml.path}'"

          # Optional
          command << "-betaDistributionEmails '#{params[:emails]}'" if params[:emails]
          command << "-betaDistributionReleaseNotesFilePath '#{params[:notes_path]}'" if params[:notes_path]
          command << "-betaDistributionGroupAliases '#{params[:groups]}'" if params[:groups]
          command << "-betaDistributionNotifications #{(params[:notifications] ? 'true' : 'false')}"

          return command
        end
      end
    end
  end
end

# java \
# -jar ~/Desktop/crashlytics-devtools.jar \
# -androidRes . \
# -uploadDist /Users/fkrause/AndroidStudioProjects/AppName/app/build/outputs/apk/app-release.apk \
# -androidManifest /Users/fkrause/Downloads/manifest.xml \
# -apiKey 016f6bbbcafe8bbce36c7278ed0eb6bb2edef5e1 \
# -apiSecret 7b77ac4a9c7d549d2171fd2bfc412c9e38ade1b5c7a6ed27190dc3a4d0cd95f8 \

# -betaDistributionReleaseNotes "Yeah" \
# -betaDistributionEmails "something11@krausefx.com" \
# -betaDistributionGroupAliases "testgroup" \
# -betaDistributionNotifications false
# -projectPath . \
