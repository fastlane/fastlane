require 'pty'

module Fastlane
  module Actions
    module SharedValues
      LANE_NAME = :LANE_NAME
      PLATFORM_NAME = :PLATFORM_NAME
      ENVIRONMENT = :ENVIRONMENT
    end

    def self.executed_actions
      @executed_actions ||= []
    end

    # The shared hash can be accessed by any action and contains information like the screenshots path or beta URL
    def self.lane_context
      @lane_context ||= {}
    end

    # Used in tests to get a clear lane before every test
    def self.clear_lane_context
      @lane_context = nil
    end

    # Pass a block which should be tracked. One block = one testcase
    # @param step_name (String) the name of the currently built code (e.g. snapshot, sigh, ...)
    #   This might be nil, in which case the step is not printed out to the terminal
    def self.execute_action(step_name)
      start = Time.now # before the raise block, since `start` is required in the ensure block
      raise 'No block given'.red unless block_given?

      error = nil
      exc = nil

      begin
        Helper.log_alert("Step: " + step_name) if step_name
        yield
      rescue => ex
        exc = ex
        error = caller.join("\n") + "\n\n" + ex.to_s
      end
    ensure
      # This is also called, when the block has a return statement
      if step_name
        duration = Time.now - start

        executed_actions << {
          name: step_name,
          error: error,
          time: duration
        }
      end

      raise exc if exc
    end

    # returns a list of official integrations
    # rubocop:disable Style/AccessorMethodName
    def self.get_all_official_actions
      Dir[File.expand_path('*.rb', File.dirname(__FILE__))].collect do |file|
        File.basename(file).gsub('.rb', '').to_sym
      end
    end
    # rubocop:enable Style/AccessorMethodName

    def self.load_default_actions
      Dir[File.expand_path('*.rb', File.dirname(__FILE__))].each do |file|
        require file
      end
    end

    # Import all the helpers
    def self.load_helpers
      Dir[File.expand_path('../helper/*.rb', File.dirname(__FILE__))].each do |file|
        require file
      end
    end

    def self.load_external_actions(path)
      raise 'You need to pass a valid path' unless File.exist?(path)

      Dir[File.expand_path('*.rb', path)].each do |file|
        require file

        file_name = File.basename(file).gsub('.rb', '')

        class_name = file_name.fastlane_class + 'Action'
        begin
          class_ref = Fastlane::Actions.const_get(class_name)

          if class_ref.respond_to?(:run)
            Helper.log.info "Successfully loaded custom action '#{file}'.".green
          else
            Helper.log.error "Could not find method 'run' in class #{class_name}.".red
            Helper.log.error 'For more information, check out the docs: https://github.com/KrauseFx/fastlane'
            raise "Plugin '#{file_name}' is damaged!"
          end
        rescue NameError
          # Action not found
          Helper.log.error "Could not find '#{class_name}' class defined.".red
          Helper.log.error 'For more information, check out the docs: https://github.com/KrauseFx/fastlane'
          raise "Plugin '#{file_name}' is damaged!"
        end
      end
    end
  end
end
