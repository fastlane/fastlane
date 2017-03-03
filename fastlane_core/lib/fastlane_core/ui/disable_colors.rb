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
    define_method(extra) do
      self # do nothing with the string, but return it
    end
  end
end
