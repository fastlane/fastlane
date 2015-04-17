module Fastlane
  class Runner

    # This will take care of executing **one** lane. 
    # @param lane_name The name of the lane to execute
    # @param platform The name of the platform to execute
    def execute(lane, platform = nil)
      raise "No lane given" unless lane

      lane = lane.to_sym

      platform = platform.to_sym if platform # might be nil, which is okay => root element

      Actions.lane_context[Actions::SharedValues::PLATFORM_NAME] = platform # set this in any case: important

      full_lane_name = [platform, lane].reject(&:nil?).join(' ')
      Helper.log.info "Driving the lane '#{full_lane_name}'".green
      Actions.lane_context[Actions::SharedValues::LANE_NAME] = full_lane_name
      ENV["FASTLANE_LANE_NAME"] = full_lane_name

      return_val = nil

      path_to_use = Fastlane::FastlaneFolder.path || Dir.pwd
      Dir.chdir(path_to_use) do # the file is located in the fastlane folder

        # Call the platform specific before_all block and then the general one
        before_all_blocks[platform].call(lane) if (before_all_blocks[platform] and platform != nil)
        before_all_blocks[nil].call(lane) if before_all_blocks[nil]
        
        return_val = nil

        if blocks[platform][lane]
          return_val = blocks[platform][lane].call
        else
          # This should never been shown when normally used
          raise "Could not find lane '#{lane}'. Available lanes: #{available_lanes.join(', ')}".red
        end

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
      blocks.each do |platform, lane| 
        next if (filter_platform and filter_platform.to_s != platform.to_s) # skip actions that don't match

        lane.each do |lane_name, block|
          all << [platform, lane_name].reject(&:nil?).join(' ')
        end
      end
      all
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
    def set_block(lane, platform, block, desc = nil)
      blocks[platform] ||= {}
      description_blocks[platform] ||= {}

      raise "Lane '#{lane}' was defined multiple times!".red if blocks[platform][lane]
      
      blocks[platform][lane] = block
      description_blocks[platform][lane] = desc
    end

    def blocks
      @blocks ||= {}
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

    def description_blocks
      @description_blocks ||= {}
    end
  end
end
