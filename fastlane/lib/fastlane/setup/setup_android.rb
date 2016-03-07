module Fastlane
  class SetupAndroid < Setup
    def run
      if FastlaneFolder.setup? and !Helper.is_test?
        Helper.log.info "Fastlane already set up at path #{folder}".yellow
        return
      end

      response = agree('Do you have everything commited in version control? If not please do so now! (y/n)'.yellow, true)
      return unless response

      FastlaneFolder.create_folder! unless Helper.is_test?
      FileUtils.mkdir(File.join(folder, 'actions')) unless File.directory?(File.join(folder, 'actions'))
      generate_appfile
      generate_fastfile
      show_analytics

      init_supply

      Helper.log.info 'Successfully finished setting up fastlane'.green
    end

    def generate_appfile
      Helper.log.info '------------------------------'
      Helper.log.info 'To not re-enter your packagename and issuer every time you run one of the fastlane tools or fastlane, these will be stored in a so-called Appfile.'.green

      package_name = ask('Package Name (com.krausefx.app): '.yellow)
      puts ""
      puts "To automatically upload builds and metadata to Google Play, fastlane needs a service action json secret file".yellow
      puts "Feel free to just click Enter to skip not provide certain things"
      puts "Follow the Setup Guide on how to get the Json file: https://github.com/fastlane/fastlane/tree/master/supply#setup".yellow
      json_key_file = ask('Path to the json secret file: '.yellow)

      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/AppfileTemplateAndroid")
      template.gsub!('[[JSON_KEY_FILE]]', json_key_file)
      template.gsub!('[[PACKAGE_NAME]]', package_name)
      path = File.join(folder, 'Appfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your preferred app metadata information.".green
    end

    def generate_fastfile
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/FastfileTemplateAndroid")

      template.gsub!('[[FASTLANE_VERSION]]', Fastlane::VERSION)

      path = File.join(folder, 'Fastfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your own deployment lanes.".green
    end

    def init_supply
      Helper.log.info ""
      question = "Do you plan on uploading metadata, screenshots and builds to Google Play using fastlane?".yellow
      Helper.log.info question
      Helper.log.info "This will download your existing metadata and screenshots into the `fastlane` folder"
      if agree(question + " (y/n) ", true)
        begin
          require 'supply'
          require 'supply/setup'
          Supply.config = FastlaneCore::Configuration.create(Supply::Options.available_options, {})
          Supply::Setup.new.perform_download
        rescue => ex
          Helper.log.error ex.to_s
          Helper.log.error "supply failed, but don't worry, you can launch supply using `supply init` whenever you want.".red
        end
      else
        Helper.log.info "You can run `supply init` to do so at a later point.".green
      end
    end

    def folder
      FastlaneFolder.path
    end
  end
end
