# references
# normal implementation:
# https://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html
# https://github.com/ruby/ruby/blob/trunk/lib/shellwords.rb
# "tests":
# https://github.com/ruby/ruby/blob/trunk/test/test_shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/spec/ruby/library/shellwords/shellwords_spec.rb
# other windows implementation:
# https://github.com/larskanis/shellwords/tree/master/test

# shellescape

shellescape_testcases = [
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
      'other'   => 'escapes the double quotes with <backslash>'
    },
    'str' => '"normal_string_without_spaces"',
    'expect' => {
      'windows' => '"normal_string_without_spaces"',
      'other'   => '\"normal_string_without_spaces\"'
    }
  },
  {
    'it' => '(#5) on string with spaces that is already wrapped in double quotes',
    'it_result' => {
      'windows' => "wraps in double quotes and duplicates existing double quotes",
      'other'   => 'escapes the double quotes and spaces with <backslash>'
    },
    'str' => '"string with spaces already wrapped in double quotes"',
    'expect' => {
      'windows' => '"""string with spaces already wrapped in double quotes"""',
      'other'   => '\"string\ with\ spaces\ already\ wrapped\ in\ double\ quotes\"'
    }
  },
  {
    'it' => '(#6) on string with spaces and double quotes',
    'it_result' => {
      'windows' => "wraps in double quotes and duplicates existing double quotes",
      'other'   => 'escapes the double quotes and spaces with <backslash>'
    },
    'str' => 'string with spaces and "double" quotes',
    'expect' => {
      'windows' => '"string with spaces and ""double"" quotes"',
      'other'   => 'string\ with\ spaces\ and\ \"double\"\ quotes'
    }
  },
  {
    'it' => '(#7) on simple string with double quotes',
    'it_result' => {
      'windows' => "wraps in double quotes and duplicates existing double quotes",
      'other'   => 'escapes the double quotes and spaces with <backslash>'
    },
    'str' => 'normal_string_with_"_but_without_spaces',
    'expect' => {
      'windows' => 'normal_string_with_"_but_without_spaces',
      'other'   => 'normal_string_with_\"_but_without_spaces'
    }
  },
  # https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L120-L125
  {
    'it' => '(#8) on string with multibyte characters',
    'it_result' => {
      'windows' => "doesn't change it",
      'other'   => 'escapes the characters'
    },
    'str' => "あい",
    'expect' => {
      'windows' => "あい",
      'other'   => "\\あ\\い"
    }
  },
  # https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L64-L65
  {
    'it' => '(#9) on simple int',
    'it_result' => {
      'windows' => "doesn't change it",
      'other'   => "doesn't change it"
    },
    'str' => 3,
    'expect' => {
      'windows' => '3',
      'other'   => '3'
    }
  },
  # TODO:
  # single quotes in string
  # \ in string
  # / in string
  # special characters in string

  # "builds/test/1337 (fastlane)" => builds/test/1337\\ \\(fastlane\\)
  # \'builds/test/1337\'

  # message = "message with 'quotes' (and parens)"
  # escaped_message = "message\\ with\\ \\'quotes\\'\\ \\(and\\ parens\\)"

  # password: '\"test password\"',
  # expect(result[0]).to eq(%(security create-keychain -p \\\"test\\ password\\\" ~/Library/Keychains/test.keychain))

]

# test shellescape Windows implementation directly
describe "WindowsShellwords#shellescape" do
  os = 'windows'
  shellescape_testcases.each do |testcase|
    it testcase['it'] + ': ' + testcase['it_result'][os] do
      str = testcase['str']
      escaped = WindowsShellwords.shellescape(str)

      expect(escaped).to eq(testcase['expect'][os])
      confirm_shell_unescapes_string_correctly(str, escaped)
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
    shellescape_testcases.each do |testcase|
      it testcase['it'] + ': ' + testcase['it_result'][os] do
        str = testcase['str'].to_s
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
    shellescape_testcases.each do |testcase|
      it testcase['it'] + ': ' + testcase['it_result'][os] do
        str = testcase['str'].to_s
        escaped = str.shellescape
        expect(escaped).to eq(testcase['expect'][os])
      end
    end
  end
end

# shelljoin
# based on (reversal of) https://github.com/ruby/ruby/blob/trunk/spec/ruby/library/shellwords/shellwords_spec.rb

shelljoin_testcases = [
  {
    'it' => '(#1) on array with entry with space',
    'it_result' => {
      'windows' => 'wraps this entry in double quotes',
      'other'   => 'escapes the space in this entry'
    },
    'input' => ['a', 'b c', 'd'],
    'expect' => {
      'windows' => 'a "b c" d',
      'other'   => 'a b\ c d'
    }
  },
  {
    'it' => '(#2) on array with entry with string wrapped in double quotes and space',
    'it_result' => {
      'windows' => 'wraps the entry with space in quote, and doubles the double quotes',
      'other'   => 'escapes the double quotes and escapes the space'
    },
    'input' => ['a', '"b" c', 'd'],
    'expect' => {
      'windows' => 'a """b"" c" d',
      'other'   => 'a \"b\"\ c d'
    }
  },
  {
    'it' => '(#3) on array with entry with string wrapped in single quotes and space',
    'it_result' => {
      'windows' => 'no changes',
      'other'   => 'escapes the single quotes and space'
    },
    'input' => ['a', "'b' c", 'd'],
    'expect' => {
      'windows' => "a \"'b' c\" d",
      'other'   => "a \\'b\\'\\ c d"
    }
  },
  # https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L67-L68
  {
    'it' => '(#4) on array with entry that is funny $$',
    'it_result' => {
      'windows' => 'no idea',
      'other'   => 'no idea'
    },
    'input' => ['ps', '-p', $$],
    'expect' => {
      'windows' => "ps -p #{$$}",
      'other'   => "ps -p #{$$}"
    }
  }
]

describe "monkey patch of Array.shelljoin (via CrossplatformShellwords)" do
  describe "on Windows" do
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:windows?).and_return(true)
    end

    os = 'windows'
    shelljoin_testcases.each do |testcase|
      it testcase['it'] + ': ' + testcase['it_result'][os] do
        array = testcase['input']
        joined = array.shelljoin
        expect(joined).to eq(testcase['expect'][os])
      end
    end
  end

  describe "on other OSs (macOS, Linux)" do
    before(:each) do
      allow(FastlaneCore::Helper).to receive(:windows?).and_return(false)
    end

    os = 'other'
    shelljoin_testcases.each do |testcase|
      it testcase['it'] + ': ' + testcase['it_result'][os] do
        array = testcase['input']
        joined = array.shelljoin
        expect(joined).to eq(testcase['expect'][os])
      end
    end
  end
end

# other tests

# https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L98-L118
describe "test_frozenness: result not frozen" do
  [
    Shellwords.shellescape(''),
    Shellwords.shellescape(String.new('foo')),
    Shellwords.shellescape(''.freeze),
    Shellwords.shellescape("\n".freeze),
    Shellwords.shellescape('foo'.freeze),
    Shellwords.shelljoin(['ps'.freeze, 'ax'.freeze])
  ].each do |object|
    it 'foo' do # TODO
      expect(object.frozen?).to eq(false)
    end
  end

  [
    Shellwords.shellsplit('ps'),
    Shellwords.shellsplit('ps ax')
  ].each do |array|
    array.each do |arg|
      it 'foo' do # TODO
        expect(arg.frozen?).to eq(false), "expected arg.frozen? to return false, got #{array.inspect}"
      end
    end
  end
end
# TODO: Test for WindowsShellwords

describe "test_frozenness 2: result not frozen" do
  [
    ''.shellescape,
    String.new('foo').shellescape,
    ''.freeze.shellescape,
    "\n".freeze.shellescape,
    'foo'.freeze.shellescape,
    ['ps'.freeze, 'ax'.freeze].shelljoin
  ].each do |object|
    it 'foo' do # TODO
      expect(object.frozen?).to eq(false)
    end
  end

  [
    'ps'.shellsplit,
    'ps ax'.shellsplit
  ].each do |array|
    array.each do |arg|
      it 'foo' do # TODO
        expect(arg.frozen?).to eq(false), "expected arg.frozen? to return false, got #{array.inspect}"
      end
    end
  end
end
# TODO: Run twice, testing for both OS

# https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L72-L88
describe "test_whitespace" do
  empty = ''
  space = " "
  newline = "\n"
  tab = "\t"

  tokens = [
    empty,
    space,
    space * 2,
    newline,
    newline * 2,
    tab,
    tab * 2,
    empty,
    space + newline + tab,
    empty
  ]

  tokens.each do |token|
    it "test shellescape->shellsplit individual tokens: '#{token}'" do
      expect([token]).to eq(Shellwords.shellescape(token).shellsplit)
    end
  end

  it "test reverse shelljoin->shellsplit" do
    expect(tokens).to eq(Shellwords.shelljoin(tokens).shellsplit)
  end
end
# TODO: Test for WindowsShellwords

describe "test_whitespace 2" do
  empty = ''
  space = " "
  newline = "\n"
  tab = "\t"

  tokens = [
    empty,
    space,
    space * 2,
    newline,
    newline * 2,
    tab,
    tab * 2,
    empty,
    space + newline + tab,
    empty
  ]

  tokens.each do |token|
    it "test shellescape->shellsplit individual tokens: '#{token}'" do
      expect([token]).to eq(token.shellescape.shellsplit)
    end
  end

  it "test reverse shelljoin->shellsplit" do
    expect(tokens).to eq(tokens.shelljoin.shellsplit)
  end
end
# TODO: Run twice, testing for both OS

describe "monkey patch of Shellwords.shellescape" do
  # not implemented yet TODO
end

describe "monkey patch of Shellwords.shelljoin" do
  # not implemented yet TODO
end

# confirms that the escaped string that is generated actually
# gets turned back into the source string by the actual shell.
# abuses a `grep` (or `find`) error message because that should be cross platform
def confirm_shell_unescapes_string_correctly(string, escaped)
  compare_string = string.to_s.dup

  if FastlaneCore::CommandExecutor.which('grep')
    if FastlaneCore::Helper.windows?
      compare_string = simulate_windows_shell_unwrapping(compare_string)
    elsif
      compare_string = simulate_normal_shell_unwrapping(compare_string)
    end
    compare_command = "grep 'foo' #{escaped}"
    expected_compare_error = "grep: " + compare_string + ": No such file or directory"
  elsif FastlaneCore::CommandExecutor.which('find')
    compare_string = simulate_normal_shell_unwrapping(compare_string)
    compare_string = compare_string.upcase
    compare_command = "find \"foo\" #{escaped}"
    expected_compare_error = "File not found - " + compare_string
  end

  # https://stackoverflow.com/a/18623297/252627, last variant
  require 'open3'
  Open3.popen3(compare_command) do |stdin, stdout, stderr, thread|
    error = stderr.read.chomp
    # expect(error).to eq(expected_compare_error)
    expect(error).to eq(expected_compare_error) # match(/#{expected_compare_error}/)
  end
end

# remove double quote pairs
# un-double-double quote resulting string
def simulate_windows_shell_unwrapping(string)
  regex = /^"(([^"])(\S*)([^"]))"$/
  unless string.to_s.match(regex).nil?
    string = string.to_s.match(regex)[1] # get only part in quotes
    string.to_s.gsub!('""', '"') # remove double double quotes
  end
  return string
end

# remove all double quotes completely
def simulate_normal_shell_unwrapping(string)
  string.gsub!('"', '')
  return string
end
