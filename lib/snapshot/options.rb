require 'fastlane_core'

module Snapshot
  class Options
    def self.available_options
      @@options ||= [
        FastlaneCore::ConfigItem.new(key: :devices,
                                     description: "A list of devices you want to take the screenshots from",
                                     is_string: false,
                                     optional: true,
                                     verify_block: Proc.new do |value|
                                       raise "Devices must be an array" unless value.kind_of?Array
                                       available = Simulators.available_devices(name_only: true)
                                       value.each do |current|
                                         unless available.include?current
                                           raise "Device '#{current}' not in list of avaiable simulators '#{available.join(', ')}'"
                                         end
                                       end
                                     end),
        FastlaneCore::ConfigItem.new(key: :languages,
                                     description: "A list of languages which should be used",
                                     is_string: false,
                                     default_value: [
                                      'de-DE',
                                      'en-US'
                                     ]),
        FastlaneCore::ConfigItem.new(key: :ios_version,
                                     description: "By default, the latest version should be used automatically. If you want to change it, do it here",
                                     default_value: Snapshot::LatestIosVersion.version),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     env_name: 'SNAPSHOT_SCHEME',
                                     description: "The scheme you want to use, this must be the scheme for the UI Tests",
                                     optional: true, # optional true because we offer a picker to the user
                                     verify_block: Proc.new do |value|
                                        project_path = Snapshot.config[:project_path]
                                        if project_path
                                          schemes = all_schemes(project_path)
                                          unless schemes.include?value
                                            raise "Could not find requested scheme '#{value}' in the project's schemes #{schemes}"
                                          end
                                        end
                                     end),
        FastlaneCore::ConfigItem.new(key: :project_path,
                                     env_name: 'SNAPSHOT_PROJECT_PATH',
                                     description: "Where is your project (or workspace)? Provide the full path here",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :screenshots_path,
                                     env_name: 'SNAPSHOT_PROJECT_PATH',
                                     description: "The path, in which the screenshots should be stored",
                                     default_value: './screenshots'),
        FastlaneCore::ConfigItem.new(key: :html_title,
                                     env_name: 'SNAPSHOT_HTML_TITLE',
                                     description: "The title that is shown on the the browser window in the HTML summary",
                                     default_value: 'KrauseFx/snapshot'),
        FastlaneCore::ConfigItem.new(key: :custom_args,
                                     env_name: 'SNAPSHOT_CUSTOM_ARGS',
                                     description: "TODO",
                                     default_value: ''),
        FastlaneCore::ConfigItem.new(key: :custom_build_args,
                                     env_name: 'SNAPSHOT_CUSTOM_BUILD_ARGS',
                                     description: "TODO",
                                     default_value: 'KrauseFx/snapshot',
                                     default_value: ''),
      ]
    end

    # Fetch all available schemes for a given project
    def self.all_schemes(project_path)
      project_key = 'project'
      project_key = 'workspace' if project_path.end_with?'.xcworkspace'
      command = "xcodebuild -#{project_key} '#{project_path}' -list"
      Helper.log.debug command if $verbose

      schemes = `#{command}`.split("Schemes:").last.split("\n").each { |a| a.strip! }.delete_if { |a| a == '' }
      Helper.log.debug "Found available schemes: #{schemes}" if $verbose

      return schemes
    end


    # This is needed as these are more complex default values
    def self.set_additional_default_values
      config = Snapshot.config

      # Devices
      unless config[:devices]
        value = Simulators.available_devices(name_only: true)
        # Now, we get multiple iPads, but we only need an iPad Air
        # [
        #  "iPad 2",
        #  "iPad Air",
        #  "iPad Air 2",
        #  "iPad Retina"
        # ]
        value.delete_if { |a| a.include?"iPad" and a != "iPad Air" }
        config[:devices] = value
      end

      # Project Path
      unless config[:project_path]
        folders = ["./*.xcworkspace"] # we prefer workspaces
        folders << "./*.xcodeproj"
        folders << "../*.xcworkspace"
        folders << "../*.xcodeproj"

        folders.each do |current|
          config[:project_path] ||= (File.expand_path(Dir[current].first) rescue nil)
        end
      end

      # Scheme
      unless config[:scheme]
        schemes = all_schemes(config[:project_path])
        config[:scheme] = schemes.first if schemes.count == 0
      end

      unless config[:scheme]
        # We have to ask the user first
        puts "Found the following schemes in your project:".green
        puts "You can use 'scheme \"Name\"' in your Snapfile".green
        puts "--------------------------------------------".green
        while not schemes.include?config[:scheme]
          schemes.each_with_index do |current, index|
            puts "#{index + 1}) #{current}"
          end
          val = gets.strip.to_i
          if val > 0
            config[:scheme] = (schemes[val - 1] rescue nil)
          end
        end

        
      end
    end
  end
end
