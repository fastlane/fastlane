module Fastlane
  class Runner

    def execute(key)
      key = key.to_sym
      Helper.log.info "Driving the lane '#{key}'".green
      Actions.lane_context[Actions::SharedValues::LANE_NAME] = key

      return_val = nil

      path_to_use = Fastlane::FastlaneFolder.path || Dir.pwd
      Dir.chdir(path_to_use) do # the file is located in the fastlane folder
        @before_all.call(key) if @before_all
        
        return_val = nil

        if blocks[key]
          return_val = blocks[key].call
        else
          raise "Could not find lane for type '#{key}'. Available lanes: #{available_lanes.join(', ')}".red
        end

        @after_all.call(key) if @after_all # this is only called if no exception was raised before
      end

      return return_val
    rescue => ex
      Dir.chdir(path_to_use) do
        # Provide error block exception without colour code
        error_ex = ex.exception(ex.message.gsub(/\033\[\d+m/, ''))
        @error.call(key, error_ex) if @error # notify the block
      end
      raise ex
    end

    def available_lanes
      blocks.keys
    end

    # Called internally
    def set_before_all(block)
      @before_all = block
    end

    def set_after_all(block)
      @after_all = block
    end

    def set_error(block)
      @error = block
    end

    def set_block(key, block)
      raise "Lane '#{key}' was defined multiple times!".red if blocks[key]
      blocks[key] = block
    end

    private

    def blocks
      @blocks ||= {}
    end
  end
end
