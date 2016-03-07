module FastlaneCore
  class XcodebuildListOutputParser
    attr_reader :configurations
    attr_reader :schemes
    attr_reader :targets

    def initialize(output)
      @configurations = []
      @schemes = []
      @targets = []
      current = nil
      output.split("\n").each do |line|
        line = line.strip
        if line.empty?
          current = nil
        elsif line == "Targets:"
          current = @targets
        elsif line == "Schemes:"
          current = @schemes
        elsif line == "Build Configurations:"
          current = @configurations
        elsif !current.nil?
          current << line
        end
      end
    end
  end
end
