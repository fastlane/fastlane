module Fastlane
  class SetupAndroid < Setup
    def run
      response = agree('Do you have everything commited in version control? If not please do so now! (y/n)'.yellow, true)
      return unless response

      FastlaneFolder.create_folder! unless Helper.is_test?
      FileUtils.mkdir(File.join(folder, 'actions')) unless File.directory?(File.join(folder, 'actions'))
      generate_appfile
      generate_fastfile
      show_analytics

      init_supply

      UI.success('Successfully finished setting up fastlane')
    end

    def generate_appfile
      UI.message('------------------------------')
      UI.success('To not re-enter your packagename and issuer every time you run one of the fastlane tools or fastlane, these will be stored in a so-called Appfile.')

      package_name = UI.input("Package Name (com.krausefx.app): ")
      puts ""
      puts "To automatically upload builds and metadata to Google Play, fastlane needs a service action json secret file".yellow
      puts "Feel free to just click Enter to skip not provide certain things"
      puts "Follow the Setup Guide on how to get the Json file: https://github.com/fastlane/fastlane/tree/master/supply#setup".yellow
      json_key_file = UI.input("Path to the json secret file: ")

      template = File.read("#{Fastlane::ROOT}/lib/assets/AppfileTemplateAndroid")
      template.gsub!('[[JSON_KEY_FILE]]', json_key_file)
      template.gsub!('[[PACKAGE_NAME]]', package_name)
      path = File.join(folder, 'Appfile')
      File.write(path, template)
      UI.success("Created new file '#{path}'. Edit it to manage your preferred app metadata information.")
    end

    def generate_fastfile
      template = File.read("#{Fastlane::ROOT}/lib/assets/FastfileTemplateAndroid")

      template.gsub!('[[FASTLANE_VERSION]]', Fastlane::VERSION)

      path = File.join(folder, 'Fastfile')
      File.write(path, template)
      UI.success("Created new file '#{path}'. Edit it to manage your own deployment lanes.")
    end

    def init_supply
      UI.message("")
      question = "Do you plan on uploading metadata, screenshots and builds to Google Play using fastlane?".yellow
      UI.message(question)
      UI.message("This will download your existing metadata and screenshots into the `fastlane` folder")
      if agree(question + " (y/n) ", true)
        begin
          require 'supply'
          require 'supply/setup'
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, {})
          Supply::Setup.new.perform_download
        rescue => ex
          UI.error(ex.to_s)
          UI.error("supply failed, but don't worry, you can launch supply using `supply init` whenever you want.")
        end
      else
        UI.success("You can run `supply init` to do so at a later point.")
      end
    end

    def folder
      FastlaneFolder.path
    end
  end
end
