module CredentialsManager
  class CLI
    def initialize(args)
      @args = args

      parse
    end

    def execute
    end

    private

    def parse
      puts @args
    end
  end
end
