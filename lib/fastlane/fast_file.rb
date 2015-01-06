module Fastlane
  class FastFile
    attr_accessor :runner

    # @return The runner which can be executed to trigger the given actions
    def initialize(path = nil)
      if (path || '').length > 0
        raise "Could not find Fastfile at path '#{path}'".red unless File.exists?path
        @path = path
        content = File.read(path)

        parse(content)
      end
    end

    def parse(data)
      @runner = Runner.new

      Dir.chdir(Fastlane::FastlaneFolder.path || Dir.pwd) do # context: fastlane subfolder
        eval(data) # this is okay in this case
      end

      return self
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

    def say(value)
      # Overwrite this, since there is already a 'say' method defined in the Ruby standard library
      value ||= yield
      Fastlane::Actions.method('say').call([value])
    end

    def method_missing(method_sym, *arguments, &block)
      # First, check if there is a predefined method in the actions folder
      if Fastlane::Actions.respond_to?(method_sym)
        Helper.log.info "Step: #{method_sym.to_s}".green
        
        Fastlane::Actions.method(method_sym).call(arguments)
      else
        # Method not found
        raise "Could not find method '#{method_sym}'. Use `lane :name do ... end`".red
      end
    end
  end
end