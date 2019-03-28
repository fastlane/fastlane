# This code overwrites the methods from the colored gem
# via https://github.com/defunkt/colored/blob/master/lib/colored.rb

require 'colored'

class String
  Colored::COLORS.keys.each { |color| define_method(color) { self } } # do nothing with the string, but return it
  Colored::EXTRAS.keys.each { |extra| define_method(extra) { self } } # do nothing with the string, but return it
end
