module Fastlane
  class Setup
    def run
      raise "Fastlane already set up at path #{folder}".yellow if FastlaneFolder.setup?

      show_infos
      response = agree("Do you want to get started? This will move your Deliverfile and Snapfile (y/n)".yellow, true)

      if response
        response = agree("Do you have everything commited in version control? If not please do so! (y/n)".yellow, true)
        if response
          FastlaneFolder.create_folder!
          copy_existing_files
          generate_app_metadata
          generate_fastfile
        end
      end
    end

    def show_infos
      Helper.log.info "This setup will help you get up and running in no time.".green
      Helper.log.info "First, it will move the config files from `deliver` and `snapshot`".green
      Helper.log.info "into the subfolder `fastlane`.\n".green
      Helper.log.info "Fastlane will check what tools you're already using and set up".green
      Helper.log.info "the tool automatically for you. Have fun! ".green
    end

    def copy_existing_files
      files = ['Deliverfile', 'Snapfile', 'deliver', 'snapshot.js', 'SnapshotHelper.js', 'screenshots']
      files.each do |current|
        if File.exists?current
          file_name = File.basename(current)
          to_path = File.join(folder, file_name)
          Helper.log.info "Moving '#{current}' to '#{to_path}'".green
          FileUtils.mv(current, to_path)
        end
      end
    end

    def generate_app_metadata
      app_identifier = ask("App Identifier (at.felixkrause.app): ".yellow)
      apple_id = ask("Your Apple ID: ".yellow)
      template = File.read("#{Helper.gem_path}/lib/assets/AppfileTemplate")
      template.gsub!('[[APP_IDENTIFIER]]', app_identifier)
      template.gsub!('[[APPLE_ID]]', apple_id)
      path = File.join(folder, "Appfile")
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your preferred app metadata information.".green
    end

    def generate_fastfile
      template = File.read("#{Helper.gem_path}/lib/assets/FastfileTemplate")

      enabled_tools = {}
      enabled_tools[:deliver] = File.exists?(File.join(folder, 'Deliverfile'))
      enabled_tools[:snapshot] = File.exists?(File.join(folder, 'Snapfile'))
      enabled_tools[:xctool] = File.exists?('./.xctool-args')
      enabled_tools[:cocoapods] = File.exists?('./Podfile')

      template.gsub!('deliver', '# deliver') unless enabled_tools[:deliver]
      template.gsub!('snapshot', '# snapshot') unless enabled_tools[:snapshot]
      template.gsub!('sh "xctool', '# sh "xctool') unless enabled_tools[:xctool]
      template.gsub!('install_cocoapods', '# install_cocoapods') unless enabled_tools[:cocoapods]

      enabled_tools.each do |key, value|
        Helper.log.info "'#{key}' enabled.".magenta if value
        Helper.log.info "'#{key}' not enabled.".yellow unless value
      end

      path = File.join(folder, "Fastfile")
      File.write(path, template)
      Helper.log.info "Created new file '#{path}'. Edit it to manage your own deployment lanes.".green
    end

    def folder
      FastlaneFolder.path
    end
  end
end