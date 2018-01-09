module Fastlane
  class SetupAndroid < Setup
    attr_accessor :json_key_file
    attr_accessor :package_name

    def setup_android
      self.platform = :android
      self.is_swift_fastfile = false

      welcome_to_fastlane

      self.fastfile_content = fastfile_template_content
      self.appfile_content = appfile_template_content

      fetch_information_for_appfile

      FastlaneCore::FastlaneFolder.create_folder!

      init_supply

      self.append_lane([
                         "desc \"Runs all the tests\"",
                         "lane :test do",
                         "  gradle(task: \"test\")",
                         "end"
                       ])

      self.append_lane([
                         "desc \"Submit a new Beta Build to Crashlytics Beta\"",
                         "lane :beta do",
                         "  gradle(task: \"assembleRelease\")",
                         "  crashlytics",
                         "",
                         "  # sh \"your_script.sh\"",
                         "  # You can also use other beta testing services here",
                         "end"
                       ])

      self.append_lane([
                         "desc \"Deploy a new version to the Google Play\"",
                         "lane :deploy do",
                         "  gradle(task: \"assembleRelease\")",
                         "  upload_to_play_store",
                         "end"
                       ])

      self.lane_to_mention = "test"

      finish_up
    end

    def fetch_information_for_appfile
      UI.message('')
      UI.message("To avoid re-entering your package name and issuer every time you run fastlane, we'll store those in a so-called Appfile.")

      self.package_name = UI.input("Package Name (com.krausefx.app): ")
      puts("")
      puts("To automatically upload builds and metadata to Google Play, fastlane needs a service action json secret file".yellow)
      puts("Follow the Setup Guide on how to get the Json file: https://docs.fastlane.tools/actions/supply/".yellow)
      puts("Feel free to press Enter at any time in order to skip providing pieces of information when asked")
      self.json_key_file = UI.input("Path to the json secret file: ")

      self.appfile_content.gsub!("[[JSON_KEY_FILE]]", self.json_key_file)
      self.appfile_content.gsub!("[[PACKAGE_NAME]]", self.package_name)
    end

    def init_supply
      UI.message("")
      question = "Do you plan on uploading metadata, screenshots, and builds to Google Play using fastlane?".yellow
      UI.message(question)
      UI.message("We will now download your existing metadata and screenshots into the `fastlane` folder so fastlane can manage it")
      if UI.confirm("Download existing metadata and setup metadata management?")
        begin
          require 'supply'
          require 'supply/setup'
          supply_config = {
            json_key: self.json_key_file,
            package_name: self.package_name
          }
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, supply_config)
          Supply::Setup.new.perform_download
        rescue => ex
          UI.error(ex.to_s)
          UI.error("Setting up `supply` (metadata management action) failed, but don't worry, you can try setting it up again using `fastlane supply init` whenever you want.")
        end
      else
        UI.success("You can run `fastlane supply init` to set up metadata management at a later point.")
      end
    end

    def finish_up
      self.fastfile_content.gsub!(":ios", ":android")

      super
    end
  end
end
