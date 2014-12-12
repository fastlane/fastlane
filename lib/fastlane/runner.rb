module Fastlane
  class Runner

    def execute(key)
      key = key.to_sym
      Helper.log.info "Driving the lane '#{key}'".green
      return_val = nil

      Dir.chdir(Fastlane::FastlaneFolder.path) do # the file is located in the fastlane folder
        @before_all.call if @before_all
        
        return_val = nil

        if blocks[key]
          return_val = blocks[key].call
        else
          raise "Could not find lane for type '#{key}'. Available lanes: #{available_lanes.join(', ')}".red
        end

        @after_all.call if @after_all
      end

      return return_val
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

    def set_block(key, block)
      blocks[key] = block
    end

    private
      def blocks
        @blocks ||= {}
      end
  end
end