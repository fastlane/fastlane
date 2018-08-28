
# https://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html
# https://github.com/ruby/ruby/blob/trunk/lib/shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/test/test_shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/spec/ruby/library/shellwords/shellwords_spec.rb

# confirms that the escaped string that is generated actually
# gets turned back into the source string by the actual shell.
# abuses a `grep` error message because that should be cross platform
# (I'm so sorry, but this actually works)
def confirm_shell_unescapes_string_correctly(string, escaped)
  string = string.dup
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

testcases = [
  { 
    'it' => '(#1) on simple string',
    'it_result' => {
      'windows' => "doesn't change it", 
      'other'   => "doesn't change it"
    },
    'str' => 'normal_string_without_spaces',
    'expect' => {
      'windows' => 'normal_string_without_spaces',
      'other'   => 'normal_string_without_spaces'
    }
  },
  { 
    'it' => '(#2) on empty string',
    'it_result' => {
      'windows' => "wraps it in double quotes", 
      'other'   => 'wraps it in single quotes'
    },
    'str' => '',
    'expect' => {
      'windows' => '""',
      'other'   => '\'\''
    }
  },
  { 
    'it' => '(#3) on string with spaces',
    'it_result' => {
      'windows' => "wraps it in double quotes", 
      'other'   => 'escapes spaces with <backslash>'
    },
    'str' => 'string with spaces',
    'expect' => {
      'windows' => '"string with spaces"',
      'other'   => 'string\ with\ spaces'
    }
  },
  { 
    'it' => '(#4) on simple string that is already wrapped in double quotes',
    'it_result' => {
      'windows' => "doesn't touch it", 
      'other'   => 'removes double quotes' #'escapes the double quotes with <backslash>'
    },
    'str' => '"normal_string_without_spaces"',
    'expect' => {
      'windows' => '"normal_string_without_spaces"',
      'other'   => 'normal_string_without_spaces' # '\"normal_string_without_spaces\"'
    }
  },
  { 
    'it' => '(#5) on string with spaces that is already wrapped in double quotes',
    'it_result' => {
      'windows' => "wraps in double quotes and duplicates existing double quotes", 
      'other'   => 'removes the double quotes and escapes the spaces with <backslash>' # 'escapes the double quotes and spaces with <backslash>'
    },
    'str' => '"string with spaces already wrapped in double quotes"',
    'expect' => {
      'windows' => '"""string with spaces already wrapped in double quotes"""',
      'other'   => 'string\ with\ spaces\ already\ wrapped\ in\ double\ quotes' # '\"string\ with\ spaces\ already\ wrapped\ in\ double\ quotes\"'
    }
  },
  { 
    'it' => '(#6) on string with spaces and double quotes',
    'it_result' => {
      'windows' => "wraps in double quotes and duplicates existing double quotes", 
      'other'   => 'removes the double quotes and escapes the spaces with <backslash>' # 'escapes the double quotes and spaces with <backslash>'
    },
    'str' => 'string with spaces and "double" quotes',
    'expect' => {
      'windows' => '"string with spaces and ""double"" quotes"',
      'other'   => 'string\ with\ spaces\ and\ double\ quotes' # 'string\ with\ spaces\ and\ \"double\"\ quotes'
    }
  },
]

# test Windows implementation directly
describe "WindowsShellwords#shellescape" do
  os = 'windows'
  testcases.each do |testcase|
    it testcase['it'] + ': ' + testcase['it_result'][os] do
      str = testcase['str']
      escaped = WindowsShellwords.shellescape(str)
  
      expect(escaped).to eq(testcase['expect'][os])
      # confirm_shell_unescapes_string_correctly(str, escaped)
    end
  end
end

# test monkey patched method on both (simulated) OSes
describe "monkey patch of String.shellescape (via CrossplatformShellwords)" do
  describe "on Windows" do
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:windows?).and_return(true)
    end

    os = 'windows'
    testcases.each do |testcase|
      it testcase['it'] + ': ' + testcase['it_result'][os] do
        str = testcase['str']
        escaped = str.shellescape
        expect(escaped).to eq(testcase['expect'][os])
      end
    end
  end

  describe "on other OSs (macOS, Linux)" do
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:windows?).and_return(false)
    end

    os = 'other'
    testcases.each do |testcase|
      it testcase['it'] + ': ' + testcase['it_result'][os] do
        str = testcase['str']
        escaped = str.shellescape
        expect(escaped).to eq(testcase['expect'][os])
      end
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
