module Fastlane
  class Runner
    # Symbol for the current lane
    attr_accessor :current_lane

    # Symbol for the current platform
    attr_accessor :current_platform

    # @return [Hash] All the lanes available, first the platform, then the lane
    attr_accessor :lanes

    def full_lane_name
      [current_platform, current_lane].reject(&:nil?).join(' ')
    end

    # This will take care of executing **one** lane. That's when the user triggers a lane from the CLI for example
    # This method is **not** executed when switching a lane
    # @param lane_name The name of the lane to execute
    # @param platform The name of the platform to execute
    # @param parameters [Hash] The parameters passed from the command line to the lane
    def execute(lane, platform = nil, parameters = nil)
      UI.crash!("No lane given") unless lane

      self.current_lane = lane.to_sym
      self.current_platform = (platform ? platform.to_sym : nil)

      lane_obj = lanes.fetch(current_platform, {}).fetch(current_lane, nil)

      UI.user_error!("Could not find lane '#{full_lane_name}'. Available lanes: #{available_lanes.join(', ')}") unless lane_obj
      UI.user_error!("You can't call the private lane '#{lane}' directly") if lane_obj.is_private

      ENV["FASTLANE_LANE_NAME"] = current_lane.to_s
      ENV["FASTLANE_PLATFORM_NAME"] = (current_platform ? current_platform.to_s : nil)

      Actions.lane_context[Actions::SharedValues::PLATFORM_NAME] = current_platform
      Actions.lane_context[Actions::SharedValues::LANE_NAME] = full_lane_name

      UI.success("Driving the lane '#{full_lane_name}' 🚀")

      return_val = nil

      path_to_use = FastlaneCore::FastlaneFolder.path || Dir.pwd
      parameters ||= {}
      begin
        Dir.chdir(path_to_use) do # the file is located in the fastlane folder
          execute_flow_block(before_all_blocks, current_platform, current_lane, parameters)
          execute_flow_block(before_each_blocks, current_platform, current_lane, parameters)

          return_val = lane_obj.call(parameters) # by default no parameters

          # after blocks are only called if no exception was raised before
          # Call the platform specific after block and then the general one
          execute_flow_block(after_each_blocks, current_platform, current_lane, parameters)
          execute_flow_block(after_all_blocks, current_platform, current_lane, parameters)
        end

        return return_val
      rescue => ex
        Dir.chdir(path_to_use) do
          # Provide error block exception without color code
          begin
            error_blocks[current_platform].call(current_lane, ex, parameters) if current_platform && error_blocks[current_platform]
            error_blocks[nil].call(current_lane, ex, parameters) if error_blocks[nil]
          rescue => error_block_exception
            UI.error("An error occurred while executing the `error` block:")
            UI.error(error_block_exception.to_s)
            raise ex # raise the original error message
          end
        end

        raise ex
      end
    end

    # @param filter_platform: Filter, to only show the lanes of a given platform
    # @return an array of lanes (platform lane_name) to print them out to the user
    def available_lanes(filter_platform = nil)
      all = []
      lanes.each do |platform, platform_lanes|
        next if filter_platform && filter_platform.to_s != platform.to_s # skip actions that don't match

        platform_lanes.each do |lane_name, lane|
          all << [platform, lane_name].reject(&:nil?).join(' ') unless lane.is_private
        end
      end
      all
    end

    # Pass a action symbol (e.g. :deliver or :commit_version_bump)
    # and this method will return a reference to the action class
    # if it exists. In case the action with this name can't be found
    # this method will return nil.
    # This method is being called by `trigger_action_by_name` to see
    # if a given action is available (either built-in or loaded from a plugin)
    # and is also being called from the fastlane docs generator
    def class_reference_from_action_name(method_sym)
      method_str = method_sym.to_s.delete("?") # as a `?` could be at the end of the method name
      class_ref = Actions.action_class_ref(method_str)

      return class_ref if class_ref && class_ref.respond_to?(:run)
      nil
    end

    # Pass a action alias symbol (e.g. :enable_automatic_code_signing)
    # and this method will return a reference to the action class
    # if it exists. In case the action with this alias can't be found
    # this method will return nil.
    def class_reference_from_action_alias(method_sym)
      alias_found = find_alias(method_sym.to_s)
      return nil unless alias_found

      class_reference_from_action_name(alias_found.to_sym)
    end

    # lookup if an alias exists
    def find_alias(action_name)
      Actions.alias_actions.each do |key, v|
        next unless Actions.alias_actions[key]
        next unless Actions.alias_actions[key].include?(action_name)
        return key
      end
      nil
    end

    # This is being called from `method_missing` from the Fastfile
    # It's also used when an action is called from another action
    # @param from_action Indicates if this action is being trigged by another action.
    #                    If so, it won't show up in summary.
    def trigger_action_by_name(method_sym, custom_dir, from_action, *arguments)
      # First, check if there is a predefined method in the actions folder
      class_ref = class_reference_from_action_name(method_sym)
      unless class_ref
        class_ref = class_reference_from_action_alias(method_sym)
        # notify action that it has been used by alias
        if class_ref.respond_to?(:alias_used)
          orig_action = method_sym.to_s
          arguments = [{}] if arguments.empty?
          class_ref.alias_used(orig_action, arguments.first)
        end
      end

      # It's important to *not* have this code inside the rescue block
      # otherwise all NameErrors will be caught and the error message is
      # confusing
      begin
        return self.try_switch_to_lane(method_sym, arguments)
      rescue LaneNotAvailableError
        # We don't actually handle this here yet
        # We just try to use a user configured lane first
        # and only if there is none, we're gonna check for the
        # built-in actions
      end

      if class_ref
        if class_ref.respond_to?(:run)
          # Action is available, now execute it
          return self.execute_action(method_sym, class_ref, arguments, custom_dir: custom_dir, from_action: from_action)
        else
          UI.user_error!("Action '#{method_sym}' of class '#{class_name}' was found, but has no `run` method.")
        end
      end

      # No lane, no action, let's at least show the correct error message
      if Fastlane.plugin_manager.plugin_is_added_as_dependency?(PluginManager.plugin_prefix + method_sym.to_s)
        # That's a plugin, but for some reason we can't find it
        UI.user_error!("Plugin '#{method_sym}' was not properly loaded, make sure to follow the plugin docs for troubleshooting: #{PluginManager::TROUBLESHOOTING_URL}")
      elsif Fastlane::Actions.formerly_bundled_actions.include?(method_sym.to_s)
        # This was a formerly bundled action which is now a plugin.
        UI.verbose(caller.join("\n"))
        UI.user_error!("The action '#{method_sym}' is no longer bundled with fastlane. You can install it using `fastlane add_plugin #{method_sym}`")
      else
        # So there is no plugin under that name, so just show the error message generated by the lane switch
        UI.verbose(caller.join("\n"))
        UI.user_error!("Could not find action, lane or variable '#{method_sym}'. Check out the documentation for more details: https://docs.fastlane.tools/actions")
      end
    end

    #
    # All the methods that are usually called on execution
    #

    class LaneNotAvailableError < StandardError
    end

    def try_switch_to_lane(new_lane, parameters)
      block = lanes.fetch(current_platform, {}).fetch(new_lane, nil)
      block ||= lanes.fetch(nil, {}).fetch(new_lane, nil) # fallback to general lane for multiple platforms
      if block
        original_full = full_lane_name
        original_lane = current_lane

        UI.user_error!("Parameters for a lane must always be a hash") unless (parameters.first || {}).kind_of?(Hash)

        execute_flow_block(before_each_blocks, current_platform, new_lane, parameters)

        pretty = [new_lane]
        pretty = [current_platform, new_lane] if current_platform
        Actions.execute_action("Switch to #{pretty.join(' ')} lane") {} # log the action
        UI.message("Cruising over to lane '#{pretty.join(' ')}' 🚖")

        # Actually switch lane now
        self.current_lane = new_lane

        result = block.call(parameters.first || {}) # to always pass a hash
        self.current_lane = original_lane

        # after blocks are only called if no exception was raised before
        # Call the platform specific after block and then the general one
        execute_flow_block(after_each_blocks, current_platform, new_lane, parameters)

        UI.message("Cruising back to lane '#{original_full}' 🚘")
        return result
      else
        raise LaneNotAvailableError.new, "Lane not found"
      end
    end

    def execute_action(method_sym, class_ref, arguments, custom_dir: nil, from_action: false, configuration_language: nil)
      if custom_dir.nil?
        custom_dir ||= "." if Helper.test?
        custom_dir ||= ".."
      end

      verify_supported_os(method_sym, class_ref)

      begin
        # https://github.com/fastlane/fastlane/issues/11913
        # launch_context = FastlaneCore::ActionLaunchContext.context_for_action_name(method_sym.to_s, configuration_language: configuration_language, args: ARGV)
        # FastlaneCore.session.action_launched(launch_context: launch_context)

        Dir.chdir(custom_dir) do # go up from the fastlane folder, to the project folder
          # If another action is calling this action, we shouldn't show it in the summary
          # (see https://github.com/fastlane/fastlane/issues/4546)

          action_name = from_action ? nil : class_ref.step_text
          Actions.execute_action(action_name) do
            # arguments is an array by default, containing an hash with the actual parameters
            # Since we usually just need the passed hash, we'll just use the first object if there is only one
            if arguments.count == 0
              arguments = ConfigurationHelper.parse(class_ref, {}) # no parameters => empty hash
            elsif arguments.count == 1 && arguments.first.kind_of?(Hash)
              arguments = ConfigurationHelper.parse(class_ref, arguments.first) # Correct configuration passed
            elsif !class_ref.available_options
              # This action does not use the new action format
              # Just passing the arguments to this method
            else
              UI.user_error!("You have to call the integration like `#{method_sym}(key: \"value\")`. Run `fastlane action #{method_sym}` for all available keys. Please check out the current documentation on GitHub.")
            end

            if Fastlane::Actions.is_deprecated?(class_ref)
              puts("==========================================".deprecated)
              puts("This action (#{method_sym}) is deprecated".deprecated)
              puts(class_ref.deprecated_notes.to_s.deprecated) if class_ref.deprecated_notes
              puts("==========================================\n".deprecated)
            end
            class_ref.runner = self # needed to call another action form an action
            return_value = class_ref.run(arguments)

            action_completed(method_sym.to_s, status: FastlaneCore::ActionCompletionStatus::SUCCESS)

            return return_value
          end
        end
      rescue Interrupt => e
        raise e # reraise the interruption to avoid logging this as a crash
      rescue FastlaneCore::Interface::FastlaneCommonException => e # these are exceptions that we dont count as crashes
        raise e
      rescue FastlaneCore::Interface::FastlaneError => e # user_error!
        action_completed(method_sym.to_s, status: FastlaneCore::ActionCompletionStatus::USER_ERROR, exception: e)
        raise e
      rescue Exception => e # rubocop:disable Lint/RescueException
        # high chance this is actually FastlaneCore::Interface::FastlaneCrash, but can be anything else
        # Catches all exceptions, since some plugins might use system exits to get out
        action_completed(method_sym.to_s, status: FastlaneCore::ActionCompletionStatus::FAILED, exception: e)
        raise e
      end
    end

    def action_completed(action_name, status: nil, exception: nil)
      #  https://github.com/fastlane/fastlane/issues/11913
      # if exception.nil? || exception.fastlane_should_report_metrics?
      #   action_completion_context = FastlaneCore::ActionCompletionContext.context_for_action_name(action_name, args: ARGV, status: status)
      #   FastlaneCore.session.action_completed(completion_context: action_completion_context)
      # end
    end

    def execute_flow_block(block, current_platform, lane, parameters)
      # Call the platform specific block and default back to the general one
      block[current_platform].call(lane, parameters) if block[current_platform] && current_platform
      block[nil].call(lane, parameters) if block[nil]
    end

    def verify_supported_os(name, class_ref)
      if class_ref.respond_to?(:is_supported?)
        # This value is filled in based on the executed platform block. Might be nil when lane is in root of Fastfile
        platform = Actions.lane_context[Actions::SharedValues::PLATFORM_NAME]
        if platform
          unless class_ref.is_supported?(platform)
            UI.important("Action '#{name}' isn't known to support operating system '#{platform}'.")
          end
        end
      end
    end

    # Called internally to setup the runner object
    #

    # @param lane [Lane] A lane object
    def add_lane(lane, override = false)
      lanes[lane.platform] ||= {}

      if !override && lanes[lane.platform][lane.name]
        UI.user_error!("Lane '#{lane.name}' was defined multiple times!")
      end

      lanes[lane.platform][lane.name] = lane
    end

    def set_before_each(platform, block)
      before_each_blocks[platform] = block
    end

    def set_after_each(platform, block)
      after_each_blocks[platform] = block
    end

    def set_before_all(platform, block)
      unless before_all_blocks[platform].nil?
        UI.error("You defined multiple `before_all` blocks in your `Fastfile`. The last one being set will be used.")
      end
      before_all_blocks[platform] = block
    end

    def set_after_all(platform, block)
      unless after_all_blocks[platform].nil?
        UI.error("You defined multiple `after_all` blocks in your `Fastfile`. The last one being set will be used.")
      end
      after_all_blocks[platform] = block
    end

    def set_error(platform, block)
      unless error_blocks[platform].nil?
        UI.error("You defined multiple `error` blocks in your `Fastfile`. The last one being set will be used.")
      end
      error_blocks[platform] = block
    end

    def lanes
      @lanes ||= {}
    end

    def did_finish
      # to maintain compatibility with other sibling classes that have this API
    end

    def before_each_blocks
      @before_each ||= {}
    end

    def after_each_blocks
      @after_each ||= {}
    end

    def before_all_blocks
      @before_all ||= {}
    end

    def after_all_blocks
      @after_all ||= {}
    end

    def error_blocks
      @error_blocks ||= {}
    end
  end
end
