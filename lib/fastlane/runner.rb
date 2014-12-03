module FastLane
  class Runner

    def execute(key)
      @before_all.call if @before_all
      
      if blocks[key]
        blocks[key].call
      else
        raise "Could not find action for type '#{key}'".red
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