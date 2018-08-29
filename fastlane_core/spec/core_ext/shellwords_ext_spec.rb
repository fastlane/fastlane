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
  # https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L64-L65
  #3 => '3'
  # https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L67-L68
  #joined = ['ps', '-p', $$].shelljoin
  #assert_equal "ps -p #{$$}", joined
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
    shellescape_testcases.each do |testcase|
      it testcase['it'] + ': ' + testcase['it_result'][os] do
        str = testcase['str']
        escaped = str.shellescape
        expect(escaped).to eq(testcase['expect'][os])
      end
    end
  end
end

# https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L120-L125
describe("test_multibyte_characters") do
  it 'multi byte character is not changed' do
    expect("あい".shellescape).to eq("あい")
  end
end
# TODO move up to shellescape_testcases



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
]

describe "monkey patch of String.shelljoin (via CrossplatformShellwords)" do
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


# TODO: 
# single quotes in string
# \ in string
# / in string
# special characters in string
# multi byte characters in string

# https://ruby-doc.org/stdlib-2.3.0/libdoc/shellwords/rdoc/Shellwords.html
# https://github.com/ruby/ruby/blob/trunk/lib/shellwords.rb
# https://github.com/ruby/ruby/blob/trunk/test/test_shellwords.rb



# other tests

# https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L42-L61
describe "test_backslashes: slash + shellwords" do
  [
    [
      %q{/a//b///c////d/////e/ "/a//b///c////d/////e/ "'/a//b///c////d/////e/ '/a//b///c////d/////e/ },
      'a/b/c//d//e /a/b//c//d///e/ /a//b///c////d/////e/ a/b/c//d//e '
    ],
    [
      %q{printf %s /"/$/`///"/r/n},
      'printf', '%s', '"$`/"rn'
    ],
    [
      %q{printf %s "/"/$/`///"/r/n"},
      'printf', '%s', '"$`/"/r/n'
    ]
  ].map { |strs|
    it 'foo' do
      cmdline, *expected = strs.map { |str| str.tr("/", "\\\\") }
      expect(Shellwords.shellwords(cmdline)).to eq(expected)
    end
  }
end
# TODO also run for our implementation on Windows to confirm it does what it should do

# https://github.com/ruby/ruby/blob/ac543abe91d7325ace7254f635f34e71e1faaf2e/test/test_shellwords.rb#L98-L118
describe "test_frozenness: result not frozen" do
  [
    Shellwords.shellescape(String.new),
    Shellwords.shellescape(String.new('foo')),
    Shellwords.shellescape(''.freeze),
    Shellwords.shellescape("\n".freeze),
    Shellwords.shellescape('foo'.freeze),
    Shellwords.shelljoin(['ps'.freeze, 'ax'.freeze]),
  ].each { |object|
    it 'foo' do # TODO
      expect(object.frozen?).to eq(false)
    end
  }

  [
    Shellwords.shellsplit('ps'),
    Shellwords.shellsplit('ps ax'),
  ].each { |array|
    array.each { |arg|
      it 'foo' do # TODO
        expect(arg.frozen?).to eq(false), "expected arg.frozen? to return false, got #{array.inspect}"
      end
    }
  }
end
# TODO also run for our implementation on Windows to confirm it does what it should do

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

  tokens.each { |token|
    it "test shellescape->shellsplit individual tokens: '#{token}'"  do
      expect([token]).to eq(Shellwords.shellescape(token).shellsplit) # TODO
    end
  }

  it "test reverse shelljoin->shellsplit" do
    expect(tokens).to eq(Shellwords.shelljoin(tokens).shellsplit) # TODO
  end
end
# TODO also run for our implementation on Windows to confirm it does what it should do





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


# confirms that the escaped string that is generated actually
# gets turned back into the source string by the actual shell.
# abuses a `grep` error message because that should be cross platform
# (I'm so sorry, but this actually works)
def confirm_shell_unescapes_string_correctly(string, escaped)
  compare_string = string.dup
  compare_string = simulate_normal_shell_unwrapping(compare_string) unless FastlaneCore::Helper.windows?
  compare_string = simulate_windows_shell_unwrapping(compare_string) if FastlaneCore::Helper.windows?
  compare_command = "grep 'foo' #{escaped}"

  # https://stackoverflow.com/a/18623297/252627, last variant
  require 'open3'
  Open3.popen3(compare_command) do |stdin, stdout, stderr, thread|
    error = stderr.read.chomp
    compare_error = "grep: " + compare_string + ": No such file or directory"
    expect(error).to eq(compare_error)
  end
end

# remove double quote pairs
# un-double-double quote resulting string
def simulate_windows_shell_unwrapping(string)
  regex = /^"(([^"])(\S*)([^"]))"$/
  unless string.match(regex).nil?
    string = string.match(regex)[1] # get only part in quotes
    string.gsub!('""', '"') # remove double double quotes
  end
  return string
end

# remove all double quotes completely
def simulate_normal_shell_unwrapping(string)
  string.gsub!('"', '')
  return string
end