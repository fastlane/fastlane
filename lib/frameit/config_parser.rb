module Frameit
  class ConfigParser
    def parse(path)
      return nil unless File.exists?(path) # we are okay with no config at all
      JSON.parse(File.read(path))
    end
  end
end