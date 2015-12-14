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
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/AbcSize
    def execute(lane, platform = nil, parameters = nil)
      raise "No lane given" unless lane

      self.current_lane = lane.to_sym
      self.current_platform = (platform ? platform.to_sym : nil)

      lane_obj = lanes.fetch(current_platform, {}).fetch(current_lane, nil)

      raise "Could not find lane '#{full_lane_name}'. Available lanes: #{available_lanes.join(', ')}".red unless lane_obj
      raise "You can't call the private lane '#{lane}' directly" if lane_obj.is_private

      ENV["FASTLANE_LANE_NAME"] = current_lane.to_s
      ENV["FASTLANE_PLATFORM_NAME"] = (current_platform ? current_platform.to_s : nil)

      Actions.lane_context[Actions::SharedValues::PLATFORM_NAME] = current_platform
      Actions.lane_context[Actions::SharedValues::LANE_NAME] = full_lane_name

      Helper.log.info "Driving the lane '#{full_lane_name}' 🚀".green

      return_val = nil

      path_to_use = Fastlane::FastlaneFolder.path || Dir.pwd
      begin
        Dir.chdir(path_to_use) do # the file is located in the fastlane folder
          # Call the platform specific before_all block and then the general one
          before_all_blocks[current_platform].call(current_lane) if before_all_blocks[current_platform] && current_platform
          before_all_blocks[nil].call(current_lane) if before_all_blocks[nil]

          return_val = lane_obj.call(parameters || {}) # by default no parameters

          # `after_all` is only called if no exception was raised before
          # Call the platform specific before_all block and then the general one
          after_all_blocks[current_platform].call(current_lane) if after_all_blocks[current_platform] && current_platform
          after_all_blocks[nil].call(current_lane) if after_all_blocks[nil]
        end

        return return_val
      rescue => ex
        Dir.chdir(path_to_use) do
          # Provide error block exception without colour code
          error_ex = ex.exception(ex.message.gsub(/\033\[\d+m/, ''))

          error_blocks[current_platform].call(current_lane, error_ex) if error_blocks[current_platform] && current_platform
          error_blocks[nil].call(current_lane, error_ex) if error_blocks[nil]
        end
        raise ex
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/AbcSize

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

    #
    # All the methods that are usually called on execution
    #

    def try_switch_to_lane(new_lane, parameters)
      block = lanes.fetch(current_platform, {}).fetch(new_lane, nil)
      block ||= lanes.fetch(nil, {}).fetch(new_lane, nil) # fallback to general lane for multiple platforms
      if block
        original_full = full_lane_name
        original_lane = current_lane

        raise "Parameters for a lane must always be a hash".red unless (parameters.first || {}).kind_of? Hash

        pretty = [new_lane]
        pretty = [current_platform, new_lane] if current_platform
        Actions.execute_action("Switch to #{pretty.join(' ')} lane") {} # log the action
        Helper.log.info "Cruising over to lane '#{pretty.join(' ')}' 🚖".green

        # Actually switch lane now
        self.current_lane = new_lane
        collector.did_launch_action(:lane_switch)
        result = block.call(parameters.first || {}) # to always pass a hash
        self.current_lane = original_lane

        Helper.log.info "Cruising back to lane '#{original_full}' 🚘".green
        return result
      else
        # No action and no lane, raising an exception now
        Helper.log.error caller.join("\n")
        raise "Could not find action or lane '#{new_lane}'. Check out the README for more details: https://github.com/KrauseFx/fastlane".red
      end
    end

    def execute_action(method_sym, class_ref, arguments, custom_dir: '..')
      collector.did_launch_action(method_sym)

      verify_supported_os(method_sym, class_ref)

      begin
        Dir.chdir(custom_dir) do # go up from the fastlane folder, to the project folder
          Actions.execute_action(class_ref.step_text) do
            # arguments is an array by default, containing an hash with the actual parameters
            # Since we usually just need the passed hash, we'll just use the first object if there is only one
            if arguments.count == 0
              arguments = ConfigurationHelper.parse(class_ref, {}) # no parameters => empty hash
            elsif arguments.count == 1 and arguments.first.kind_of? Hash
              arguments = ConfigurationHelper.parse(class_ref, arguments.first) # Correct configuration passed
            elsif !class_ref.available_options
              # This action does not use the new action format
              # Just passing the arguments to this method
            else
              raise "You have to call the integration like `#{method_sym}(key: \"value\")`. Run `fastlane action #{method_sym}` for all available keys. Please check out the current documentation on GitHub.".red
            end

            class_ref.run(arguments)
          end
        end
      rescue => ex
        collector.did_raise_error(method_sym)
        raise ex
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

    def collector
      @collector ||= ActionCollector.new
    end

    # Fastfile was finished executing
    def did_finish
      collector.did_finish
    end

    # Called internally to setup the runner object
    #

    # @param lane [Lane] A lane object
    def add_lane(lane, override = false)
      lanes[lane.platform] ||= {}

      if !override and lanes[lane.platform][lane.name]
        raise "Lane '#{lane.name}' was defined multiple times!".red
      end

      lanes[lane.platform][lane.name] = lane
    end

    def set_before_all(platform, block)
      before_all_blocks[platform] = block
    end

    def set_after_all(platform, block)
      after_all_blocks[platform] = block
    end

    def set_error(platform, block)
      error_blocks[platform] = block
    end

    def lanes
      @lanes ||= {}
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
