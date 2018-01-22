require_relative 'module'

module Frameit
  # Represents the MiniMagick trim bounding box for cropping a text image
  class Trimbox
    attr_accessor :width # width of the trim box
    attr_accessor :height # height of the trim box
    attr_accessor :offset_x # horizontal offset from the canvas to the trim box
    attr_accessor :offset_y # vertical offset from the canvas to the trim box

    # identify_string: A string with syntax "<width>x<height>+<offset_x>+<offset_y>". This is returned by MiniMagick when using function .identify with format("%@"). It is also required for the MiniMagick .crop function.
    def initialize(identify_string)
      UI.user_error!("Trimbox can not be initialised with an empty 'identify_string'.") unless identify_string.length > 0

      # Parse the input syntax "<width>x<height>+<offset_x>+<offset_y>".
      # Extract these 4 parameters into an integer array, by using multiple string separators: "x" and "+":
      trim_values = identify_string.split(/[x+]/).map(&:to_i)

      # If 'identify_string' doesn't have the expected syntax with 4 parameters, show error:
      UI.user_error!("Trimbox is initialised with an invalid value for 'identify_string'.") unless trim_values.length == 4

      # Assign instance variables:
      @width = trim_values[0]
      @height = trim_values[1]
      @offset_x = trim_values[2]
      @offset_y = trim_values[3]
    end

    # Get the trimbox parameters in the MiniMagick string format
    def string_format
      # Convert trim box parameters to string with syntax: "<width>x<height>+<offset_x>+<offset_y>":
      return "#{@width}x#{@height}+#{@offset_x}+#{@offset_y}"
    end
  end
end
