module Fastlane
  class Runner
    LaneConfig = Struct.new(:name, :block, :dependencies, :description) do
      def verify_no_circular_dependencies(runner, platform, visited_set = [])
        raise "Circular dependencies detected for lane '#{name}' with dependency chain: #{visited_set.map{|v| v.name }.join " -> "} -> #{name}".red if visited_set.include? self
        dependencies.each do |dependency|
          dependency = runner.find_config_for_platform(dependency, platform)
          dependency.verify_no_circular_dependencies(runner, platform, visited_set.clone << self)
        end
      end

      def call
        block.call
      end
    end

    # This will take care of executing **one** lane. 
    # @param lane_name The name of the lane to execute
    # @param platform The name of the platform to execute
    def execute(lane, platform = nil)
      raise "No lane given" unless lane

      ENV["FASTLANE_LANE_NAME"] = lane.to_s
      if platform
        ENV["FASTLANE_PLATFORM_NAME"] = platform.to_s
      else
        ENV["FASTLANE_PLATFORM_NAME"] = nil
      end
      
      lane = lane.to_sym
      platform = platform.to_sym if platform # might be nil, which is okay => root element

      Actions.lane_context[Actions::SharedValues::PLATFORM_NAME] = platform # set this in any case: important

      full_lane_name = [platform, lane].reject(&:nil?).join(' ')
      Helper.log.info "Driving the lane '#{full_lane_name}'".green
      Actions.lane_context[Actions::SharedValues::LANE_NAME] = full_lane_name

      return_val = nil

      path_to_use = Fastlane::FastlaneFolder.path || Dir.pwd
      Dir.chdir(path_to_use) do # the file is located in the fastlane folder
        unless (configs[platform][lane] rescue nil)
          raise "Could not find lane '#{full_lane_name}'. Available lanes: #{available_lanes.join(', ')}".red
        end

        # Call the platform specific before_all block and then the general one
        before_all_blocks[platform].call(lane) if (before_all_blocks[platform] and platform != nil)
        before_all_blocks[nil].call(lane) if before_all_blocks[nil]
        
        return_val = run_lane(configs[platform][lane], platform)
        
        # `after_all` is only called if no exception was raised before
        # Call the platform specific before_all block and then the general one
        after_all_blocks[platform].call(lane) if (after_all_blocks[platform] and platform != nil)
        after_all_blocks[nil].call(lane) if (after_all_blocks[nil])
      end

      return return_val
    rescue => ex
      Dir.chdir(path_to_use) do
        # Provide error block exception without colour code
        error_ex = ex.exception(ex.message.gsub(/\033\[\d+m/, ''))

        error_blocks[platform].call(lane, error_ex) if (error_blocks[platform] and platform != nil)
        error_blocks[nil].call(lane, error_ex) if error_blocks[nil]
      end
      raise ex
    end

    # @param filter_platform: Filter, to only show the lanes of a given platform
    def available_lanes(filter_platform = nil)
      all = []
      configs.each do |platform, lane| 
        next if (filter_platform and filter_platform.to_s != platform.to_s) # skip actions that don't match

        lane.each do |lane_name, config|
          all << [platform, lane_name].reject(&:nil?).join(' ')
        end
      end
      all
    end

    def run_lane(lane_config, platform)
      run_dependencies(lane_config, platform)
      Helper.log.info "Dependencies finished successfully 🎊  Driving back to '#{lane_config.name}'...".green
      lane_config.call
    end

    def run_dependencies(lane_config, platform)
      Helper.log.info "Running dependencies for lane '#{lane_config.name}'...".green unless lane_config.dependencies.empty? 

      lane_config.dependencies.each do |dependency|
        dependency_config = find_config_for_platform dependency, platform
        raise "Lane configuration not found for the dependency '#{dependency.to_s}' on platform #{platform}" if dependency_config.nil?

        run_dependencies(dependency_config, platform)

        Helper.log.info "Cruising over to lane '#{dependency_config.name}'...🚖".green
        dependency_config.call
      end
    end

    # Tries to find the config by the dependency name (symbol) for the current platform
    # Platforms shadow the root configuration, so if a lane is specialized for a platform the specialization is used
    def find_config_for_platform(dependency, platform)
      [platform, nil].uniq.each do |current_platform|
        config = configs[current_platform][dependency]
        return config unless config.nil?
      end
    end

    # Called internally
    def set_before_all(platform, block)
      before_all_blocks[platform] = block
    end

    def set_after_all(platform, block)
      after_all_blocks[platform] = block
    end

    def set_error(platform, block)
      error_blocks[platform] = block
    end

    # @param lane: The name of the lane
    # @param platform: The platform for the given block - might be nil - nil is actually the root of Fastfile with no specific platform
    # @param block: The block of the lane
    # @param desc: Description of this action
    def set_block(lane, platform, block, dependencies = [], desc = nil)
      configs[platform] ||= {}

      raise "Lane '#{lane}' was defined multiple times!".red if configs[platform][lane]
      
      configs[platform][lane] = LaneConfig.new(lane, block, dependencies, desc)
    end

    def configs
      @configs ||= {}
    end

    # Keep old inteface to outside the same
    def blocks
      configs
    end
    def description_blocks
      desc_blocks = {}
      configs.each do |platform, lanes|
        desc_blocks[platform] = {}
        lanes.each do |lane_name, config| 
          desc_blocks[platform][lane_name] = config.description
        end
      end

      desc_blocks
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
