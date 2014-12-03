module FastLane
  class Runner

    def execute(key)
      key = key.to_sym
      Helper.log.info "Driving the lane '#{key}'".green

      @before_all.call if @before_all
      
      if blocks[key]
        blocks[key].call
      else
        raise "Could not find action for type '#{key}'. Available lanes: #{blocks.keys.join(', ')}".red
      end
    end

    # Called internally
    def set_before_all(block)
      @before_all = block
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