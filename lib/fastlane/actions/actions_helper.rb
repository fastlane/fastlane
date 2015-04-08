require 'pty'

module Fastlane
  module Actions
    module SharedValues
      LANE_NAME = :LANE_NAME
      ENVIRONMENT = :ENVIRONMENT
    end

    def self.executed_actions
      @executed_actions ||= []
    end

    # The shared hash can be accessed by any action and contains information like the screenshots path or beta URL
    def self.lane_context
      @lane_context ||= {}
    end

    # Pass a block which should be tracked. One block = one testcase
    # @param step_name (String) the name of the currently built code (e.g. snapshot, sigh, ...)
    def self.execute_action(step_name)
      raise 'No block given'.red unless block_given?

      start = Time.now
      error = nil
      exc = nil

      begin
        yield
      rescue => ex
        exc = ex
        error = caller.join("\n") + "\n\n" + ex.to_s
      end
    ensure
      # This is also called, when the block has a return statement
      duration = Time.now - start

      executed_actions << {
        name: step_name,
        error: error,
        time: duration
        # output: captured_output
      }
      raise exc if exc
    end

    # Execute a shell command
    # This method will output the string and execute it
    def self.sh(command)
      sh_no_action(command)
    end

    def self.sh_no_action(command)
      command = command.join(' ') if command.is_a?(Array) # since it's an array of one element when running from the Fastfile
      Helper.log.info ['[SHELL COMMAND]', command.yellow].join(': ')

      result = ''
      unless Helper.test?
        exit_status = nil
        status = IO.popen(command, err: [:child, :out]) do |io|
          io.each do |line|
            Helper.log.info ['[SHELL OUTPUT]', line.strip].join(': ')
            result << line
          end
          io.close
          exit_status = $?.to_i
        end

        if exit_status != 0
          # this will also append the output to the exception (for the Jenkins reports)
          raise "Exit status of command '#{command}' was #{exit_status} instead of 0. \n#{result}"
        end
      else
        result << command # only for the tests
      end

      result
    end

    # Returns the current git branch - can be replaced using the environment variable `GIT_BRANCH`
    def self.git_branch
      return ENV['GIT_BRANCH'].gsub /origin\//, '' if ENV['GIT_BRANCH'].to_s.length > 0 # set by Jenkins
      s = `git rev-parse --abbrev-ref HEAD`
      return s.to_s.strip if s.to_s.length > 0
      nil
    end 

    def self.load_default_actions
      Dir[File.expand_path '*.rb', File.dirname(__FILE__)].each do |file|
        require file
      end
    end

    def self.load_external_actions(path)
      raise 'You need to pass a valid path' unless File.exist?(path)

      Dir[File.expand_path '*.rb', path].each do |file|
        require file

        file_name = File.basename(file).gsub('.rb', '')

        class_name = file_name.fastlane_class + 'Action'
        class_ref = nil
        begin
          class_ref = Fastlane::Actions.const_get(class_name)

          if class_ref.respond_to?(:run)
            Helper.log.info "Successfully loaded custom action '#{file}'.".green
          else
            Helper.log.error "Could not find method 'run' in class #{class_name}.".red
            Helper.log.error 'For more information, check out the docs: https://github.com/KrauseFx/fastlane'
            raise "Plugin '#{file_name}' is damaged!"
          end
        rescue NameError => ex
          # Action not found
          Helper.log.error "Could not find '#{class_name}' class defined.".red
          Helper.log.error 'For more information, check out the docs: https://github.com/KrauseFx/fastlane'
          raise "Plugin '#{file_name}' is damaged!"
        end
      end
    end
  end
end
