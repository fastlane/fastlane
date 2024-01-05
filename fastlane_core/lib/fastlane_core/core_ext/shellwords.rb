require_relative '../helper'
require 'shellwords'

# Here be monkey patches

class String
  # CrossplatformShellwords
  def shellescape
    CrossplatformShellwords.shellescape(self)
  end
end

class Array
  def shelljoin
    CrossplatformShellwords.shelljoin(self)
  end
end

# Here be helper

module CrossplatformShellwords
  # handle switching between implementations of shellescape
  def shellescape(str)
    if FastlaneCore::Helper.windows?
      WindowsShellwords.shellescape(str)
    else
      # using `escape` instead of expected `shellescape` here
      # which corresponds to Shellword's `String.shellescape` implementation
      # https://github.com/ruby/ruby/blob/1cf2bb4b2085758112503e7da7414d1ef52d4f48/lib/shellwords.rb#L216
      Shellwords.escape(str)
    end
  end
  module_function :shellescape

  # make sure local implementation is also used in shelljoin
  def shelljoin(array)
    array.map { |arg| shellescape(arg) }.join(' ')
  end
  module_function :shelljoin
end

# Windows implementation
module WindowsShellwords
  def shellescape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    # https://github.com/ruby/ruby/blob/a6413848153e6c37f6b0fea64e3e871460732e34/lib/shellwords.rb#L142-L143
    return '""'.dup if str.empty?

    str = str.dup

    # wrap in double quotes if contains space
    if str =~ /\s/
      # double quotes have to be doubled if will be quoted
      str.gsub!('"', '""')
      return '"' + str + '"'
    else
      return str
    end
  end
  module_function :shellescape
end
