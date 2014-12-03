module FastLane
  class FastFile
    attr_accessor :runner

    # @return The runner which can be executed to trigger the given actions
    def initialize(path)
      raise "Could not find Fastfile at path '#{path}'".red unless File.exists?path

      @path = path
      @runner = Runner.new

      content = File.read(path)

      eval(content) # this is okay in this case
    end

    def lane(key, &block)
      @runner.set_block(key, block)
    end

    def before_all(&block)
      @runner.set_before_all(block)
    end

    def after_all(&block)
      @runner.set_after_all(block)
    end

    def method_missing(method_sym, *arguments, &block)
      raise "Could not find method '#{method_sym}'. Use `lane :name do ... end`".red
    end
  end
end