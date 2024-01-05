# This code overwrites the methods from the colored gem
# via https://github.com/defunkt/colored/blob/master/lib/colored.rb

require 'colored'

class String
  Colored::COLORS.keys.each do |color|
    define_method(color) do
      self # do nothing with the string, but return it
    end
  end
  Colored::EXTRAS.keys.each do |extra|
    next if extra == 'clear'
    define_method(extra) do
      self # do nothing with the string, but return it
    end
  end
end

# If a plugin uses the colorize gem, we also want to disable that
begin
  require 'colorize'
  String.disable_colorization = true
rescue LoadError
  # Colorize gem is not used by any plugin
end
