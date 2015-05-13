module Snapshot
  class SnapshotConfig
    
    # @return (SnapshotFile)
    attr_accessor :snapshot_file

    # @return (Array) List of simulators to use
    attr_accessor :devices

    # @return (Array) A list of languages which should be used
    attr_accessor :languages
    
    # @return (String) The iOS version (e.g. 8.1)
    attr_accessor :ios_version

    # @return (String) The path to the project/workspace
    attr_accessor :project_path

    # @return (String) The name of a scheme, manually set by the user using the config file
    attr_accessor :manual_scheme

    # @return (String) The path to the JavaScript file to use
    attr_accessor :manual_js_file

    # @return (String) The path, in which the screenshots should be stored
    attr_accessor :screenshots_path

    # @return (String) The build command, wich should build the app to build_dir (/tmp/snapshot by default)
    attr_accessor :build_command

    # @return (String) The build directory, defaults to '/tmp/snapshot'
    attr_accessor :build_dir

    # @return (BOOL) Skip the removal of the alpha channel from the screenshots
    attr_accessor :skip_alpha_removal

    # @return (BOOL) Clear previously generated screenshots before creating new ones
    attr_accessor :clear_previous_screenshots

    # @return (String) This will be prepended before the actual build command
    attr_accessor :custom_args
    
    # @return (String) This will be appended to the actual build command
    attr_accessor :custom_build_args

    # @return (String) This will be appended to the run command
    attr_accessor :custom_run_args

    # @return (Hash) All the blocks, which are called on specific actions
    attr_accessor :blocks

    attr_accessor :html_title


    # A shared singleton
    def self.shared_instance(path = nil)
      @@instance ||= SnapshotConfig.new(path)
    end

    # @param path (String) the path to the config file to use (including the file name)
    def initialize(path = nil)
      DependencyChecker.check_simulators
      path ||= './Snapfile'
      set_defaults

      if File.exists?path
        Helper.log.info "Using '#{path}'".green if $verbose
        self.snapshot_file = SnapshotFile.new(path, self)

        self.verify_devices
      else
        if path != './Snapfile'
          raise "Could not find Snapfile at path '#{path}'. Make sure you pass the full path, including 'Snapfile'".red
        else
          # Using default settings, since user didn't provide a path
          Helper.log.error "Could not find './Snapfile'. It is recommended to create a file using 'snapshot init' into the current directory. Using the defaults now.".red
          self.verify_devices
        end
      end

      load_env
    end

    def set_defaults
      self.ios_version = Snapshot::LatestIosVersion.version

      self.languages = [
        'de-DE',
        'en-US'
      ]

      self.screenshots_path = './screenshots'

      folders = ["./*.xcworkspace"] # we prefer workspaces
      folders << "./*.xcodeproj"
      folders << "../*.xcworkspace"
      folders << "../*.xcodeproj"

      folders.each do |current|
        self.project_path ||= (File.expand_path(Dir[current].first) rescue nil)
      end

      empty = Proc.new {}
      self.blocks = {
        setup_for_device_change: empty, 
        teardown_device: empty,
        setup_for_language_change: empty,
        teardown_language: empty
      }

      self.html_title = self.project_name || 'KrauseFx/snapshot'

    end

    # This has to be done after parsing the Snapfile (iOS version)
    def set_default_simulators
      self.devices ||= [
        "iPhone 6 (#{self.ios_version} Simulator)",
        "iPhone 6 Plus (#{self.ios_version} Simulator)",
        "iPhone 5 (#{self.ios_version} Simulator)",
        "iPhone 4s (#{self.ios_version} Simulator)"
      ]
    end

    # This method takes care of appending the iOS version to the simulator name
    def verify_devices
      self.set_default_simulators

      actual_devices = []
      self.devices.each do |current|
        current += " (#{self.ios_version} Simulator)" unless current.include?"Simulator"

        unless Simulators.available_devices.include?current
          raise "Device '#{current}' not found. Available device types: #{Simulators.available_devices}".red
        else
          actual_devices << current
        end
      end
      self.devices = actual_devices
    end

    def load_env
      # Load environment variables
      self.manual_scheme = ENV["SNAPSHOT_SCHEME"] if ENV["SNAPSHOT_SCHEME"]
      self.screenshots_path = ENV["SNAPSHOT_SCREENSHOTS_PATH"] if ENV["SNAPSHOT_SCREENSHOTS_PATH"]
    end

    # Getters

    # Returns the file name of the project
    def project_name
      File.basename(self.project_path, ".*" ) if self.project_path
    end

    # The JavaScript UIAutomation file
    def js_file(ipad = false)
      return ENV["SNAPSHOT_JS_FILE"] if ENV["SNAPSHOT_JS_FILE"]
      
      result = manual_js_file

      unless result
        files = Dir.glob("./*.js").delete_if { |path| (path.include?"SnapshotHelper.js" or path.include?"iPad.js") }
        if files.count == 1
          result = files.first
        end
      end

      if ipad
        ipad_file = result.split('.js').join('/') + '-iPad.js'
        if File.exists?(ipad_file)
          result = ipad_file
        end
      end

      unless File.exists?(result || '')
        raise "Could not determine which UIAutomation file to use. Please pass a path to your Javascript file using 'js_file'.".red
      end

      return result
    end

    # The scheme to use (either it's set, or there is only one, or user has to enter it)
    def scheme
      begin
        project_key = 'project'
        project_key = 'workspace' if project_path.end_with?'.xcworkspace'
        command = "xcodebuild -#{project_key} '#{project_path}' -list"
        Helper.log.debug command if $verbose
        
        schemes = `#{command}`.split("Schemes:").last.split("\n").each { |a| a.strip! }.delete_if { |a| a == '' }
        
        Helper.log.debug "Found available schemes: #{schemes}" if $verbose

        self.manual_scheme = schemes.first if schemes.count == 1

        if self.manual_scheme
          if not schemes.include?manual_scheme
            raise "Could not find requested scheme '#{self.manual_scheme}' in Xcode's schemes #{schemes}"
          else
            return self.manual_scheme
          end
        else
          # We have to ask the user first
          puts "Found the following schemes in your project:".green
          puts "You can use 'scheme \"Name\"' in your Snapfile".green
          puts "--------------------------------------------".green
          while not schemes.include?self.manual_scheme
            schemes.each_with_index do |current, index|
              puts "#{index + 1}) #{current}"
            end
            val = gets.strip.to_i
            if val > 0
              self.manual_scheme = (schemes[val - 1] rescue nil)
            end
          end
          return self.manual_scheme
        end
      rescue => ex
        raise "Could not fetch available schemes: #{ex}".red
      end
    end
  end
end