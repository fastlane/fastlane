def raise_fastlane_error
  raise_error(FastlaneCore::Interface::FastlaneError)
end

def raise_fastlane_test_failure
  raise_error(FastlaneCore::Interface::FastlaneTestFailure)
end

# The following methods is taken from activesupport,
#
# https://github.com/rails/rails/blob/d66e7835bea9505f7003e5038aa19b6ea95ceea1/activesupport/lib/active_support/core_ext/string/strip.rb
#
# All credit for this method goes to the original authors.
# The code is used under the MIT license.
#
# Strips indentation by removing the amount of leading whitespace in the least indented non-empty line in the whole string
#
def strip_heredoc(str)
  str.gsub(/^#{str.scan(/^[ \t]*(?=\S)/).min}/, "".freeze)
end
