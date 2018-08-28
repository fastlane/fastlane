
# https://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html
# https://github.com/ruby/ruby/blob/trunk/lib/shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/test/test_shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/spec/ruby/library/shellwords/shellwords_spec.rb

# confirms that the escaped string that is generated actually
# gets turned back into the source string by the actual shell.
# abuses a `grep` error message because that should be cross platform
# (I'm so sorry, but this actually works)
def confirm_shell_unescapes_string_correctly(string, escaped)
  string = simulate_normal_shell_unwrapping(string) unless FastlaneCore::Helper.windows?
  string = simulate_windows_shell_unwrapping(string) if FastlaneCore::Helper.windows?
  compare_command = "grep 'foo' #{escaped}"

  # https://stackoverflow.com/a/18623297/252627, last variant
  require 'open3'
  Open3.popen3(compare_command) do |stdin, stdout, stderr, thread|
    error = stderr.read.chomp
    compare_error = "grep: " + string + ": No such file or directory"
    expect(error).to eq(compare_error)
  end
end

# remove double quote pair
# un-double-double quote resulting string
def simulate_windows_shell_unwrapping(string)
  regex = /^"(([^"])(\S*)([^"]))"$/
  unless string.match(regex).nil?
    string = string.match(regex)[1] # get only part in quotes
    string.gsub!('""', '"') # remove double double quotes
  end
  return string
end

# remove all double quotes
def simulate_normal_shell_unwrapping(string)
  string.gsub!('"', '')
  return string
end

# test Windows implementation directly
describe "WindowsShellwords#shellescape" do
  it "on simple string: doesn't change it" do
    str = 'normal_string_without_spaces'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq(str)
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "on empty string: wraps it in double quotes" do
    str = ''
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('""')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "on string with spaces: wraps it in double quotes" do
    str = 'string with spaces'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"string with spaces"')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "on simple string that is already wrapped in double quotes: doesn't touch it" do
    str = '"normal_string_without_spaces"'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"normal_string_without_spaces"')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "on string with spaces that is already wrapped in double quotes: wraps in double quotes and duplicates existing double quotes" do
    str = '"string with spaces already wrapped in double quotes"'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"""string with spaces already wrapped in double quotes"""')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "on string with spaces and double quotes: wraps in double quotes and duplicates existing double quotes" do
    str = 'string with spaces and "double" quotes'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"string with spaces and ""double"" quotes"')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end
end

describe "monkey patch of String.shellescape (via CrossplatformShellwords)" do
  describe "on Windows" do
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:windows?).and_return(true)
    end

    it "on simple string: doesn't change it" do
      str = 'normal_string_without_spaces'
      escaped = str.shellescape
      expect(escaped).to eq(str)
    end

    it "on empty string: wraps it in double quotes" do
      str = ''
      escaped = str.shellescape
      expect(escaped).to eq('""')
    end

    it "on string with spaces: wraps it in double quotes" do
      str = 'string with spaces'
      escaped = str.shellescape
      expect(escaped).to eq('"string with spaces"')
    end

    it "on simple string that is already wrapped in double quotes: doesn't touch it" do
      str = '"normal_string_without_spaces"'
      escaped = str.shellescape
      expect(escaped).to eq('"normal_string_without_spaces"')
    end

    it "on string with spaces that is already wrapped in double quotes: wraps in double quotes and duplicates existing double quotes" do
      str = '"string with spaces already wrapped in double quotes"'
      escaped = str.shellescape
      expect(escaped).to eq('"""string with spaces already wrapped in double quotes"""')
    end

    it "on string with spaces and double quotes: wraps in double quotes and duplicates existing double quotes" do
      str = 'string with spaces and "double" quotes'
      escaped = str.shellescape
      expect(escaped).to eq('"string with spaces and ""double"" quotes"')
    end
  end

  describe "on other OSs (macOS, Linux)" do
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:windows?).and_return(false)
    end

    it "on simple string: doesn't change it" do
      str = 'normal_string_without_spaces'
      escaped = str.shellescape
      expect(escaped).to eq(str)
    end

    it "on empty string: wraps it in single quotes" do
      str = ''
      escaped = str.shellescape 
      expect(escaped).to eq('\'\'')
    end

    it "on string with spaces: escapes spaces with <backslash>" do
      str = 'string with spaces'
      escaped = str.shellescape
      expect(escaped).to eq('string\ with\ spaces')
    end

    it "on simple string that is already wrapped in double quotes: escapes the double quotes with <backslash>" do
      str = '"normal_string_without_spaces"'
      escaped = str.shellescape
      expect(escaped).to eq('\"normal_string_without_spaces\"')
    end

    it "on string with spaces that is already wrapped in double quotes: escapes the double quotes and spaces with <backslash>" do
      str = '"string with spaces already wrapped in double quotes"'
      escaped = str.shellescape
      expect(escaped).to eq('\"string\ with\ spaces\ already\ wrapped\ in\ double\ quotes\"')
    end

    it "on string with spaces and double quotes: escapes the double quotes and spaces with <backslash>" do
      str = 'string with spaces and "double" quotes'
      escaped = str.shellescape
      expect(escaped).to eq('string\ with\ spaces\ and\ \"double\"\ quotes')
    end
  end
end

# TODO: 
# single quotes in string
# \ in string
# / in string
# special characters in string
# multi byte characters in string

describe "monkey patch of Array.shelljoin (via CrossplatformShellwords)" do
  # TODO
end

describe "monkey patch of Shellwords.shellescape" do
  # not implemented yet
end

describe "monkey patch of Shellwords.shelljoin" do
  # not implemented yet
end

# "builds/test/1337 (fastlane)" => builds/test/1337\\ \\(fastlane\\)
# \'builds/test/1337\'

# message = "message with 'quotes' (and parens)"
# escaped_message = "message\\ with\\ \\'quotes\\'\\ \\(and\\ parens\\)"

# password: '\"test password\"',
# expect(result[0]).to eq(%(security create-keychain -p \\\"test\\ password\\\" ~/Library/Keychains/test.keychain))
