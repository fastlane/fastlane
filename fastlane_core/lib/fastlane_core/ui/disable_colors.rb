# This code overwrites the methods from the colored gem
# via https://github.com/kigster/colored2/blob/aa274018906641ffb07aaa3015081a174d169dfe/lib/colored2.rb

require 'colored2'

class String
  Colored2::COLORS.keys.each do |color|
    define_method(color) do
      self # do nothing with the string, but return it
    end
  end
  Colored2::EXTRAS.keys.each do |extra|
    define_method(extra) do
      self # do nothing with the string, but return it
    end
  end
end
