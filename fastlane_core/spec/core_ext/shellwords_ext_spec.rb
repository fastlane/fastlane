
# https://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html
# https://github.com/ruby/ruby/blob/trunk/lib/shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/test/test_shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/spec/ruby/library/shellwords/shellwords_spec.rb

# used to confirm that the escaped command that is generated actually 
# gets turned back into the source string by the actual shell.
# abuses a `grep` error message because that should be cross platform
def confirm_shell_unescapes_string_correctly(string, escaped)
  string = simulate_windows_shell_unwrapping(string)
  
  compare_command = "grep 'foo' #{escaped}"
  puts 'execute command: ' + compare_command
  
  # https://stackoverflow.com/a/18623297/252627, last variant
  require 'open3'
  Open3.popen3(compare_command) do |stdin, stdout, stderr, thread|
    error = stderr.read.chomp
    compare_error = "grep: " + string + ": No such file or directory"
    expect(error).to eq(compare_error)
  end
end

def simulate_windows_shell_unwrapping(string)
  regex = /^"(([^"])(\S*)([^"]))"$/
  unless string.match(regex).nil?
    puts 'string before mod: ' + string
    string = string.match(regex)[1]
    puts 'string after mod: ' + string
  end
  return string
end

# test Windows implementation directly
describe "WindowsShellwords#shellescape" do
  it "doesn't touch a simple string" do
    str = 'normal_string_without_spaces'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq(str)
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "double quotes an empty string" do
    str = ''
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('""')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "double quotes a string with spaces" do
    str = 'string with spaces'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"string with spaces"')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "wraps in double quotes and double-double quotes a string with spaces and double quotes" do
    str = 'string with spaces and "double" quotes'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"string with spaces and ""double"" quotes"')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "doesn't touch a simple string that starts and ends with double quotes" do
    str = '"normal_string_without_spaces"'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"normal_string_without_spaces"')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end

  it "???" do
    str = '"string with spaces already wrapped in double quotes"'
    escaped = WindowsShellwords.shellescape(str)

    expect(escaped).to eq('"""string with spaces already wrapped in double quotes"""')
    confirm_shell_unescapes_string_correctly(str, escaped)
  end
end

describe "monkey patch of String.shellescape (via CrossplatformShellwords)" do
end

describe "monkey patch of Array.shelljoin (via CrossplatformShellwords)" do
end

describe "monkey patch of Shellwords.shellescape" do
  # not implemented yet
end

describe "monkey patch of Shellwords.shelljoin" do
  # not implemented yet
end





#"builds/test/1337 (fastlane)" => builds/test/1337\\ \\(fastlane\\)
#\'builds/test/1337\'

#message = "message with 'quotes' (and parens)"
#escaped_message = "message\\ with\\ \\'quotes\\'\\ \\(and\\ parens\\)"

#password: '\"test password\"',
#expect(result[0]).to eq(%(security create-keychain -p \\\"test\\ password\\\" ~/Library/Keychains/test.keychain))
