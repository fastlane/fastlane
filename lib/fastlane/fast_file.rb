module Fastlane
  class FastFile
    attr_accessor :runner

    # @return The runner which can be executed to trigger the given actions
    def initialize(path = nil)
      return unless (path || '').length > 0
      raise "Could not find Fastfile at path '#{path}'".red unless File.exist?(path)
      @path = path
      content = File.read(path)

      parse(content)
    end

    def collector
      @collector ||= ActionCollector.new
    end

    def parse(data)
      @runner = Runner.new

      Dir.chdir(Fastlane::FastlaneFolder.path || Dir.pwd) do # context: fastlane subfolder
        eval(data) # this is okay in this case
      end

      self
    end

    def lane(key, &block)
      @runner.set_block(key, block)
    end

    def before_all(&block)
      @runner.set_before_all(block)
    end

    def after_all(&block)
      @runner.set_after_all(block)
    end

    def error(&block)
      @runner.set_error(block)
    end

    # Speak out loud
    def say(value)
      # Overwrite this, since there is already a 'say' method defined in the Ruby standard library
      value ||= yield
      Actions.execute_action('say') do
        Fastlane::Actions::SayAction.run([value])
      end
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

    # Fastfile was finished executing
    def did_finish
      collector.did_finish
    end

    def method_missing(method_sym, *arguments, &_block)
      # First, check if there is a predefined method in the actions folder

      class_name = method_sym.to_s.fastlane_class + 'Action'
      class_ref = nil
      begin
        class_ref = Fastlane::Actions.const_get(class_name)
      rescue NameError => ex
        # Action not found
        raise "Could not find method '#{method_sym}'. Check out the README for more details: https://github.com/KrauseFx/fastlane".red
      end

      if class_ref && class_ref.respond_to?(:run)
        collector.did_launch_action(method_sym)

        step_name = class_ref.step_text rescue nil
        step_name = method_sym.to_s unless step_name
        Helper.log_alert("Step: " + step_name)

        begin
          Dir.chdir('..') do # go up from the fastlane folder, to the project folder
            Actions.execute_action(method_sym) do
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
  end
end
