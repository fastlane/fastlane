module Fastlane
  module Actions
    module SharedValues
      LANE_NAME = :LANE_NAME
      PLATFORM_NAME = :PLATFORM_NAME
      ENVIRONMENT = :ENVIRONMENT

      # A slightly decorated hash that will store and fetch sensitive data
      # but not display it while iterating keys and values
      class LaneContextValues < Hash
        def initialize
          @sensitive_context = {}
        end

        def set_sensitive(key, value)
          @sensitive_context[key] = value
        end

        def [](key)
          if @sensitive_context.key?(key)
            return @sensitive_context[key]
          end
          super
        end
      end
    end

    def self.reset_aliases
      @alias_actions = nil
    end

    def self.alias_actions
      unless @alias_actions
        @alias_actions = {}
        ActionsList.all_actions do |action, name|
          next unless action.respond_to?(:aliases)
          @alias_actions[name] = action.aliases
        end
      end
      @alias_actions
    end

    def self.executed_actions
      @executed_actions ||= []
    end

    # The shared hash can be accessed by any action and contains information like the screenshots path or beta URL
    def self.lane_context
      @lane_context ||= SharedValues::LaneContextValues.new
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
      UI.crash!("No block given") unless block_given?

      error = nil
      exc = nil

      begin
        UI.header("Step: " + step_name) if step_name
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
    # rubocop:disable Naming/AccessorMethodName
    def self.get_all_official_actions
      Dir[File.expand_path('*.rb', File.dirname(__FILE__))].collect do |file|
        File.basename(file).gsub('.rb', '').to_sym
      end
    end
    # rubocop:enable Naming/AccessorMethodName

    # Returns the class ref to the action based on the action name
    # Returns nil if the action is not available
    def self.action_class_ref(action_name)
      class_name = action_name.to_s.fastlane_class + 'Action'
      class_ref = nil
      begin
        class_ref = Fastlane::Actions.const_get(class_name)
      rescue NameError
        return nil
      end
      return class_ref
    end

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
      UI.user_error!("You need to pass a valid path") unless File.exist?(path)

      class_refs = []
      Dir[File.expand_path('*.rb', path)].each do |file|
        begin
          require file
        rescue SyntaxError => ex
          content = File.read(file, encoding: "utf-8")
          ex.to_s.lines
            .collect { |error| error.match(/#{file}:(\d+):(.*)/) }
            .reject(&:nil?)
            .each { |error| UI.content_error(content, error[1]) }
          UI.user_error!("Syntax error in #{File.basename(file)}")
          next
        end

        file_name = File.basename(file).gsub('.rb', '')

        class_name = file_name.fastlane_class + 'Action'
        begin
          class_ref = Fastlane::Actions.const_get(class_name)
          class_refs << class_ref

          if class_ref.respond_to?(:run)
            UI.success("Successfully loaded custom action '#{file}'.") if FastlaneCore::Globals.verbose?
          else
            UI.error("Could not find method 'run' in class #{class_name}.")
            UI.error('For more information, check out the docs: https://docs.fastlane.tools/')
            UI.user_error!("Action '#{file_name}' is damaged!", show_github_issues: true)
          end
        rescue NameError
          # Action not found
          UI.error("Could not find '#{class_name}' class defined.")
          UI.error('For more information, check out the docs: https://docs.fastlane.tools/')
          UI.user_error!("Action '#{file_name}' is damaged!", show_github_issues: true)
        end
      end
      Actions.reset_aliases

      return class_refs
    end

    def self.formerly_bundled_actions
      ["xcake"]
    end

    # Returns a boolean indicating whether the class
    # reference is a Fastlane::Action
    def self.is_class_action?(class_ref)
      return false if class_ref.nil?
      is_an_action = class_ref < Fastlane::Action
      return is_an_action || false
    end

    # Returns a boolean indicating if the class
    # reference is a deprecated Fastlane::Action
    def self.is_deprecated?(class_ref)
      is_class_action?(class_ref) && class_ref.category == :deprecated
    end
  end
end
