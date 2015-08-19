module Fastlane
  class FastFile
    # Stores all relevant information from the currently running process
    attr_accessor :runner

    # the platform in which we're currently in when parsing the Fastfile
    # This is used to identify the platform in which the lane is in
    attr_accessor :current_platform

    SharedValues = Fastlane::Actions::SharedValues

    # @return The runner which can be executed to trigger the given actions
    def initialize(path = nil)
      return unless (path || '').length > 0
      raise "Could not find Fastfile at path '#{path}'".red unless File.exist?(path)
      @path = File.expand_path(path)
      content = File.read(path)

      parse(content)
    end

    def parse(data)
      @runner ||= Runner.new

      Dir.chdir(Fastlane::FastlaneFolder.path || Dir.pwd) do # context: fastlane subfolder
        eval(data) # this is okay in this case
      end

      self
    end


    #####################################################
    # @!group DSL
    #####################################################

    # User defines a new lane
    def lane(lane_name, &block)
      raise "You have to pass a block using 'do' for lane '#{lane_name}'. Make sure you read the docs on GitHub.".red unless block
      
      self.runner.add_lane(Lane.new(platform: self.current_platform,
                                       block: block,
                                 description: desc_collection,
                                        name: lane_name,
                                  is_private: false))

      @desc_collection = nil # reset the collected description again for the next lane
    end

    # User defines a new private lane, which can't be called from the CLI
    def private_lane(lane_name, &block)
      raise "You have to pass a block using 'do' for lane '#{lane_name}'. Make sure you read the docs on GitHub.".red unless block

      self.runner.add_lane(Lane.new(platform: self.current_platform,
                                       block: block,
                                 description: desc_collection,
                                        name: lane_name,
                                  is_private: true))

      @desc_collection = nil # reset the collected description again for the next lane
    end

    # User defines a lane that can overwrite existing lanes. Useful when importing a Fastfile
    def override_lane(lane_name, &block)
      raise "You have to pass a block using 'do' for lane '#{lane_name}'. Make sure you read the docs on GitHub.".red unless block

      self.runner.add_lane(Lane.new(platform: self.current_platform,
                                       block: block,
                                 description: desc_collection,
                                        name: lane_name,
                                  is_private: false), true)

      @desc_collection = nil # reset the collected description again for the next lane
    end
    
    # User defines a platform block
    def platform(platform_name, &block)
      SupportedPlatforms.verify!platform_name

      self.current_platform = platform_name

      block.call

      self.current_platform = nil
    end

    # Is executed before each test run
    def before_all(&block)
      @runner.set_before_all(@current_platform, block)
    end

    # Is executed after each test run
    def after_all(&block)
      @runner.set_after_all(@current_platform, block)
    end

    # Is executed if an error occured during fastlane execution
    def error(&block)
      @runner.set_error(@current_platform, block)
    end

    # Is used to look if the method is implemented as an action
    def method_missing(method_sym, *arguments, &_block)
      # First, check if there is a predefined method in the actions folder
      class_name = method_sym.to_s.fastlane_class + 'Action'
      class_ref = nil
      begin
        class_ref = Fastlane::Actions.const_get(class_name)
      rescue NameError => ex
        # Action not found
        # Is there a lane under this name?
        return self.runner.try_switch_to_lane(method_sym, arguments)
      end

      # It's important to *not* have this code inside the rescue block
      # otherwise all NameErrors will be catched and the error message is
      # confusing
      if class_ref && class_ref.respond_to?(:run)
        # Action is available, now execute it
        return self.runner.execute_action(method_sym, class_ref, arguments)
      else
        raise "Action '#{method_sym}' of class '#{class_name}' was found, but has no `run` method.".red
      end
    end

    #####################################################
    # @!group Other things
    #####################################################

    def collector
      runner.collector
    end

    # Is the given key a platform block or a lane?
    def is_platform_block?(key)
      raise 'No key given'.red unless key

      return false if (self.runner.lanes[nil][key.to_sym] rescue false)
      return true if self.runner.lanes[key.to_sym].kind_of?Hash

      raise "Could not find '#{key}'. Available lanes: #{self.runner.available_lanes.join(', ')}".red
    end

    def actions_path(path)
      raise "Path '#{path}' not found!".red unless File.directory?(path)

      Actions.load_external_actions(path)
    end

    # Execute shell command
    def sh(command)
      Actions.execute_action(command) do
        Actions.sh_no_action(command)
      end
    end

    def desc(string)
      desc_collection << string
    end

    def desc_collection
      @desc_collection ||= []
    end

    def import(path = nil)
      raise "Please pass a path to the `import` action".red unless path

      path = path.dup.gsub("~", Dir.home)
      unless Pathname.new(path).absolute? # unless an absolute path
        path = File.join(File.expand_path('..', @path), path)
      end
      
      raise "Could not find Fastfile at path '#{path}'".red unless File.exists?(path)
      
      collector.did_launch_action(:import)
      parse(File.read(path))

      # Check if we can also import local actions which are in the same directory as the Fastfile
      actions_path = File.join(File.expand_path("..", path), 'actions')
      Fastlane::Actions.load_external_actions(actions_path) if File.directory?(actions_path)
    end

    # @param url [String] The git URL to clone the repository from
    # @param path [String] The path to the Fastfile
    def import_from_git(url: nil, path: 'fastlane/Fastfile')
      raise "Please pass a path to the `import_from_git` action".red if url.to_s.length == 0

      Actions.execute_action('import_from_git') do
        collector.did_launch_action(:import_from_git)

        # Checkout the repo
        repo_name = url.split("/").last

        folder = File.join("/tmp", "fl_clones", repo_name)

        if File.directory?folder
          Helper.log.info "Using existing git repo..."
          Actions.sh("cd '#{folder}' && git pull")
        else
          # When this fails, we have to clone the git repo
          Helper.log.info "Cloning remote git repo..."
          Actions.sh("git clone '#{url}' '#{folder}' --depth 1 -n")
        end

        Actions.sh("cd '#{folder}' && git checkout HEAD '#{path}'")

        # We also want to check out all the local actions of this fastlane setup
        containing = path.split(File::SEPARATOR)[0..-2]
        containing = "." if containing.count == 0
        actions_folder = File.join(containing, "actions")
        begin
          Actions.sh("cd '#{folder}' && git checkout HEAD '#{actions_folder}'")
        rescue => ex
          # We don't care about a failure here, as local actions are optional
        end

        import(File.join(folder, path))
      end
    end

    #####################################################
    # @!group Overwriting Ruby methods
    #####################################################

    # Speak out loud
    def say(value)
      # Overwrite this, since there is already a 'say' method defined in the Ruby standard library
      value ||= yield
      Actions.execute_action('say') do
        collector.did_launch_action(:say)
        Fastlane::Actions::SayAction.run([value])
      end
    end

    def puts(value)
      # Overwrite this, since there is already a 'puts' method defined in the Ruby standard library
      value ||= yield
      collector.did_launch_action(:puts)
      Fastlane::Actions::PutsAction.run([value])
    end
  end
end
