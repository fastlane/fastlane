require_relative '../helper'

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

module CrossplatformShellwords
  def shellescape(str)
    if FastlaneCore::Helper.windows?
      return 'windows' + WindowsShellwords.shellescape(str)
    else
      return 'not windows' + Shellwords.escape(str)
    end
  end
  module_function :shellescape

  def shelljoin(array)
    array.map { |arg| shellescape(arg) }.join(' ')
  end
  module_function :shelljoin
end

module WindowsShellwords
  def shellescape(str)
    str = str.to_s

    # An empty argument will be skipped, so return empty quotes.
    # https://github.com/ruby/ruby/blob/a6413848153e6c37f6b0fea64e3e871460732e34/lib/shellwords.rb#L142-L143
    return '""'.dup if str.empty?

    str = str.dup

    # wrap in double quotes if contains space
    # then return (and skip Shellwords.escape)
    if str =~ /\s/
      # double quotes have to be doubled
      str.gsub!('"', '""')
      return '"' + str + '"'
    else
      return str
    end
  end
  module_function :shellescape
end
