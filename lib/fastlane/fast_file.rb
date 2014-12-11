module Fastlane
  class FastFile
    attr_accessor :runner

    # @return The runner which can be executed to trigger the given actions
    def initialize(path)
      raise "Could not find Fastfile at path '#{path}'".red unless File.exists?path

      @path = path
      @runner = Runner.new

      # Load all actions
      Dir.chdir("/Users/felixkrause/Apps/fastlane/lib") do # TODO: Remove
        Dir['fastlane/actions/*.rb'].each do |file| 
          require file
        end
      end


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
      # First, check if there is a predefined method in the actions folder
      method = Fastlane::Actions.method(method_sym)
      if method
        method.call(arguments)
      else
        # Method not found
        raise "Could not find method '#{method_sym}'. Use `lane :name do ... end`".red
      end
    end
  end
end