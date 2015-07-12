module Fastlane
  class FastFile
    attr_accessor :runner

    SharedValues = Fastlane::Actions::SharedValues

    # @return The runner which can be executed to trigger the given actions
    def initialize(path = nil)
      return unless (path || '').length > 0
      raise "Could not find Fastfile at path '#{path}'".red unless File.exist?(path)
      @path = path
      content = File.read(path)

      parse(content)
    end

    def parse(data)
      @runner = Runner.new

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
      
      desc = desc_collection.join("\n\n")
      platform = @current_platform

      @runner.set_block(lane_name, platform, block, desc)

      @desc_collection = nil # reset the collected description again for the next lane
    end
    
    # User defines a platform block
    def platform(platform_name, &block)
      SupportedPlatforms.verify!platform_name

      @current_platform = platform_name

      block.call

      @current_platform = nil
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

    def try_switch_to_lane(new_lane, parameters)
      current_platform = Actions.lane_context[Actions::SharedValues::PLATFORM_NAME]
      block = @runner.blocks.fetch(current_platform, {}).fetch(new_lane, nil)
      platform_nil = (block == nil) # used for the output
      block ||= @runner.blocks.fetch(nil, {}).fetch(new_lane, nil) # fallback to general lane for multiple platforms
      if block
        pretty = [new_lane]
        pretty = [current_platform, new_lane] unless platform_nil
        Helper.log.info "Cruising over to lane '#{pretty.join(' ')}' 🚖".green
        collector.did_launch_action(:lane_switch)
        result = block.call(parameters.first || {}) # to always pass a hash
        original_lane = Actions.lane_context[Actions::SharedValues::LANE_NAME]
        Helper.log.info "Cruising back to lane '#{original_lane}' 🚘".green
        return result
      else
        # No action and no lane, raising an exception now
        raise "Could not find action or lane '#{new_lane}'. Check out the README for more details: https://github.com/KrauseFx/fastlane".red
      end
    end

    def execute_action

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
        return try_switch_to_lane(method_sym, arguments)
      end

      if class_ref && class_ref.respond_to?(:run)
        collector.did_launch_action(method_sym)

        step_name = class_ref.step_text rescue nil
        step_name = method_sym.to_s unless step_name

        verify_supported_os(method_sym, class_ref)

        Helper.log_alert("Step: " + step_name)

        begin
          Dir.chdir('..') do # go up from the fastlane folder, to the project folder
            Actions.execute_action(method_sym) do
              # arguments is an array by default, containing an hash with the actual parameters
              # Since we usually just need the passed hash, we'll just use the first object if there is only one
              if arguments.count == 0 
                arguments = ConfigurationHelper.parse(class_ref, {}) # no parameters => empty hsh
              elsif arguments.count == 1 and arguments.first.kind_of?Hash
                arguments = ConfigurationHelper.parse(class_ref, arguments.first) # Correct configuration passed
              elsif not class_ref.available_options
                # This action does not use the new action format
                # Just passing the arguments to this method
              else
                Helper.log.fatal "------------------------------------------------------------------------------------".red
                Helper.log.fatal "If you've been an existing fastlane user, please check out the MigrationGuide to 1.0".yellow
                Helper.log.fatal "https://github.com/KrauseFx/fastlane/blob/master/docs/MigrationGuide.md".yellow
                Helper.log.fatal "------------------------------------------------------------------------------------".red
                raise "You have to pass the options for '#{method_sym}' in a different way. Please check out the current documentation on GitHub!".red
              end

              class_ref.run(arguments)
            end
          end
        rescue => ex
          collector.did_raise_error(method_sym)
          raise ex
        end
      else
        raise "Action '#{method_sym}' of class '#{class_name}' was found, but has no `run` method.".red
      end
    end


    #####################################################
    # @!group Other things
    #####################################################

    # Speak out loud
    def say(value)
      # Overwrite this, since there is already a 'say' method defined in the Ruby standard library
      value ||= yield
      Actions.execute_action('say') do
        Fastlane::Actions::SayAction.run([value])
      end
    end

    # Is the given key a platform block or a lane?
    def is_platform_block?(key)
      raise 'No key given'.red unless key

      return false if (self.runner.blocks[nil][key.to_sym] rescue false)
      return true if self.runner.blocks[key.to_sym].kind_of?Hash

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

    def verify_supported_os(name, class_ref)
      if class_ref.respond_to?(:is_supported?)
        if Actions.lane_context[Actions::SharedValues::PLATFORM_NAME]
          # This value is filled in based on the executed platform block. Might be nil when lane is in root of Fastfile
          platform = Actions.lane_context[Actions::SharedValues::PLATFORM_NAME]

          unless class_ref.is_supported?(platform)
            raise "Action '#{name}' doesn't support required operating system '#{platform}'.".red 
          end
        end
      end
    end

    # Fastfile was finished executing
    def did_finish
      collector.did_finish
    end

    def desc(string)
      desc_collection << string
    end

    def collector
      @collector ||= ActionCollector.new
    end

    def desc_collection
      @desc_collection ||= []
    end
  end
end
