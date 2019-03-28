require_relative 'module'

module Frameit
  class ConfigParser
    attr_reader :data

    def load(path)
      return nil unless File.exist?(path) # we are okay with no config at all
      UI.verbose("Parsing config file '#{path}'")
      @path = path
      self.parse(File.read(path))
    end

    # @param data (String) the JSON data to be parsed
    def parse(data)
      begin
        @data = JSON.parse(data)
      rescue => ex
        UI.error(ex.message)
        UI.user_error!(
          "Invalid JSON file at path '#{@path}'. Make sure it's a valid JSON file"
        )
      end

      self
    end

    # Fetches the finished configuration for a given path. This will try to look for a specific value
    # and fallback to a default value if nothing was found
    def fetch_value(path)
      specifics = @data['data'].select { |a| path.include?(a['filter']) }

      default = @data['default']

      values = default.clone
      specifics.each do |specific|
        values = values.fastlane_deep_merge(specific)
      end

      change_paths_to_absolutes!(values)
      validate_values(values)

      values
    end

    # Use absolute paths instead of relative
    def change_paths_to_absolutes!(values)
      values.each do |key, value|
        if value.kind_of?(Hash)
          change_paths_to_absolutes!(value) # recursive call
        elsif value.kind_of?(Array)
          value.each do |current|
            change_paths_to_absolutes!(current) if current.kind_of?(Hash) # recursive call
          end
        else
          if %w[font background].include?(key) # where is the config file. We don't have a config file in tests
            # Change the paths to relative ones
            # `replace`: to change the content of the string, so it's actually stored
            if @path
              containing_folder = File.expand_path('..', @path)
              value.replace(File.join(containing_folder, value))
            end
          end
        end
      end
    end

    # Make sure the paths/colors are valid
    def validate_values(values)
      values.each do |key, value|
        value.kind_of?(Hash) ? validate_values(value) : validate_key(key, value) # recursive call
      end
    end

    def validate_key(key, value)
      case key
      when 'font'
        unless File.exist?(value)
          UI.user_error!(
            "Could not find font at path '#{File.expand_path(value)}'"
          )
        end
      when 'fonts'
        UI.user_error!('`fonts` must be an array') unless value.kind_of?(Array)

        value.each do |current|
          if current.fetch('font', '').length == 0
            UI.user_error!('You must specify a font path')
          end
          unless File.exist?(current.fetch('font'))
            UI.user_error!(
              "Could not find font at path '#{File.expand_path(
                current.fetch('font')
              )}'"
            )
          end
          unless current.fetch('supported', []).kind_of?(Array)
            UI.user_error!('`supported` must be an array')
          end
        end
      when 'background'
        unless File.exist?(value)
          UI.user_error!(
            "Could not find background image at path '#{File.expand_path(
              value
            )}'"
          )
        end
      when 'color'
        unless value.include?('#')
          UI.user_error!("Invalid color '#{value}'. Must be valid Hex #123123")
        end
      when 'padding'
        unless integer_or_percentage(value) || value.split('x').length == 2
          UI.user_error!(
            "padding must be an integer, or pair of integers of format 'AxB', or a percentage of screen size"
          )
        end
      when 'title_min_height'
        unless integer_or_percentage(value)
          UI.user_error!(
            'padding must be an integer, or a percentage of screen size'
          )
        end
      when 'show_complete_frame', 'title_below_image'
        unless [true, false].include?(value)
          UI.user_error!("'#{key}' must be a Boolean")
        end
      when 'font_scale_factor'
        unless value.kind_of?(Numeric)
          UI.user_error!('font_scale_factor must be numeric')
        end
      when 'frame'
        unless %w[BLACK WHITE GOLD ROSE_GOLD].include?(value)
          UI.user_error!('device must be BLACK, WHITE, GOLD, ROSE_GOLD')
        end
      end
    end

    def integer_or_percentage(value)
      value.kind_of?(Integer) || (value.end_with?('%') && value.to_f > 0)
    end
  end
end
