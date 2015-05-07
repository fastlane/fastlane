module Frameit
  class ConfigParser
    def load(path)
      return nil unless File.exists?(path) # we are okay with no config at all
      Helper.log.info "Parsing config file '#{path}'".yellow if $verbose
      @path = path
      self.parse(File.read(path))
    end



    # @param data (String) the JSON data to be parsed
    def parse(data)
      begin
        @data = JSON.parse(data)
      rescue => ex
        Helper.log.fatal ex
        raise "Invalid JSON file at path '#{@path}'. Make sure it's a valid JSON file".red
      end

      self
    end

    # Fetches the finished configuration for a given path. This will try to look for a specific value
    # and fallback to a default value if nothing was found
    def fetch_value(path)
      specific = @data['data'].find { |a| path.include?a['filter'] }
      Helper.log.info "Could not find specific value for path '#{path}'".yellow unless specific
      
      default = @data['default']

      values = default.fastlane_deep_merge(specific || {})

      validate_values(values)

      values
    end

    # Make sure the paths/colors are valid
    def validate_values(values)
      values.each do |key, value|
        if value.kind_of?Hash
          validate_values(value) # recursive call
        else
          if key == 'font'
            raise "Could not find font at path '#{File.expand_path(value)}'" unless File.exists?value
          end

          if key == 'background'
            raise "Could not find background image at path '#{File.expand_path(value)}'" unless File.exists?value
          end

          if key == 'color'
            raise "Invalid color '#{value}'. Must be valid Hex #123123" unless value.include?"#"
          end

          if key == 'padding'
            raise "padding must be type integer" unless value.kind_of?Integer
          end
        end
      end
    end
  end
end