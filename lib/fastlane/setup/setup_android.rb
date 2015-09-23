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
      FileUtils.mkdir(File.join(folder, 'actions'))
      generate_fastfile
      show_analytics
      Helper.log.info ""
      Helper.log.info "If you want to upload app metadata and builds to Google Play".green
      Helper.log.info "run `supply init`".green
      Helper.log.info 'Successfully finished setting up fastlane'.green
    end

    def generate_fastfile
      template = File.read("#{Helper.gem_path('fastlane')}/lib/assets/FastfileTemplateAndroid")

      template.gsub!('[[FASTLANE_VERSION]]', Fastlane::VERSION)

      path = File.join(folder, 'Fastfile')
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your own deployment lanes.".green
    end

    def folder
      FastlaneFolder.path
    end
  end
end
