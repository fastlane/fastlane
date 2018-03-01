require 'shellwords'

module Fastlane
  module Helper
    class CrashlyticsHelper
      class << self
        def discover_default_crashlytics_path
          path = Dir["./Pods/iOS/Crashlytics/Crashlytics.framework"].last || Dir["./**/Crashlytics.framework"].last
          unless path
            UI.user_error!("Couldn't find Crashlytics.framework in current directory. Make sure to add the 'Crashlytics' pod to your 'Podfile' and run `pod update`")
          end
          return path
        end

        def generate_ios_command(params)
          params[:crashlytics_path] ||= discover_default_crashlytics_path

          UI.user_error!("No value found for 'crashlytics_path'") unless params[:crashlytics_path]
          submit_binary = Dir[File.join(params[:crashlytics_path], '**', 'submit')].last
          submit_binary ||= "Crashlytics.framework/submit" if Helper.test?
          UI.user_error!("Could not find submit binary in crashlytics bundle at path '#{params[:crashlytics_path]}'") unless submit_binary

          command = []
          command << submit_binary.shellescape
          command << params[:api_token]
          command << params[:build_secret]
          command << "-ipaPath '#{params[:ipa_path]}'"
          command << "-emails '#{params[:emails]}'" if params[:emails]
          command << "-notesPath '#{params[:notes_path]}'" if params[:notes_path]
          command << "-groupAliases '#{params[:groups]}'" if params[:groups]
          command << "-notifications #{(params[:notifications] ? 'YES' : 'NO')}"
          command << "-debug #{(params[:debug] ? 'YES' : 'NO')}"

          return command
        end

        def generate_android_command(params)
          # We have to generate an empty XML file to make the crashlytics CLI happy :)
          require 'tempfile'
          xml = Tempfile.new('xml')
          xml.write('<?xml version="1.0" encoding="utf-8"?><manifest></manifest>')
          xml.close

          params[:crashlytics_path] = download_android_tools unless params[:crashlytics_path]

          UI.user_error!("The `crashlytics_path` must be a jar file for Android") unless params[:crashlytics_path].end_with?(".jar") || Helper.test?

          if ENV['JAVA_HOME'].nil?
            command = ["java"]
          else
            command = [Shellwords.escape(File.join(ENV['JAVA_HOME'], "/bin/java"))]
          end
          command << "-jar #{File.expand_path(params[:crashlytics_path])}"
          command << "-androidRes ."
          command << "-apiKey #{params[:api_token]}"
          command << "-apiSecret #{params[:build_secret]}"
          command << "-uploadDist '#{File.expand_path(params[:apk_path])}'"
          command << "-androidManifest '#{xml.path}'"

          # Optional
          command << "-betaDistributionEmails '#{params[:emails]}'" if params[:emails]
          command << "-betaDistributionReleaseNotesFilePath '#{File.expand_path(params[:notes_path])}'" if params[:notes_path]
          command << "-betaDistributionGroupAliases '#{params[:groups]}'" if params[:groups]
          command << "-betaDistributionNotifications #{(params[:notifications] ? 'true' : 'false')}"

          return command
        end

        def download_android_tools
          containing = File.join(File.expand_path("~/Library"), "CrashlyticsAndroid")
          zip_path = File.join(containing, "crashlytics-devtools.zip")
          jar_path = File.join(containing, "crashlytics-devtools.jar")
          return jar_path if File.exist?(jar_path)

          url = "https://ssl-download-crashlytics-com.s3.amazonaws.com/android/ant/crashlytics.zip"
          require 'net/http'

          FileUtils.mkdir_p(containing)

          begin
            UI.important("Downloading Crashlytics Support Library - this might take a minute...")

            # Work around ruby defect, where HTTP#get_response and HTTP#post_form don't use ENV proxy settings
            # https://bugs.ruby-lang.org/issues/12724
            uri = URI(url)
            http_conn = Net::HTTP.new(uri.host, uri.port)
            http_conn.use_ssl = true
            result = http_conn.request_get(uri.path)
            UI.error!("#{result.message} (#{result.code})") unless result.kind_of?(Net::HTTPSuccess)
            File.write(zip_path, result.body)

            # Now unzip the file
            Action.sh("unzip '#{zip_path}' -d '#{containing}'")

            UI.user_error!("Couldn't find 'crashlytics-devtools.jar'") unless File.exist?(jar_path)

            UI.success("Successfully downloaded Crashlytics Support Library to '#{jar_path}'")
          rescue => ex
            UI.user_error!("Error fetching remote file: #{ex}")
          end

          return jar_path
        end

        def write_to_tempfile(value, tempfilename)
          require 'tempfile'

          Tempfile.new(tempfilename).tap do |t|
            t.write(value)
            t.close
          end
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
# -apiKey api_key \
# -apiSecret secret_key \

# -betaDistributionReleaseNotes "Yeah" \
# -betaDistributionEmails "something11@krausefx.com" \
# -betaDistributionGroupAliases "testgroup" \
# -betaDistributionNotifications false
# -projectPath . \
