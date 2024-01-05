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
  # baseline
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
  # spaces
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
  # double quotes
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
  {
    'it' => '(#7) on simple int',
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
  # single quotes
  {
    'it' => '(#8) on simple string that is already wrapped in single quotes',
    'it_result' => {
      'windows' => "doesn't touch it",
      'other'   => 'escapes the single quotes with <backslash>'
    },
    'str' => "'normal_string_without_spaces'",
    'expect' => {
      'windows' => "'normal_string_without_spaces'",
      'other'   => "\\'normal_string_without_spaces\\'"
    }
  },
  {
    'it' => '(#9) on string with spaces that is already wrapped in single quotes',
    'it_result' => {
      'windows' => "wraps in double quotes",
      'other'   => 'escapes the single quotes and spaces with <backslash>'
    },
    'str' => "'string with spaces already wrapped in single quotes'",
    'expect' => {
      'windows' => "\"'string with spaces already wrapped in single quotes'\"",
      'other'   => "\\'string\\ with\\ spaces\\ already\\ wrapped\\ in\\ single\\ quotes\\'"
    }
  },
  {
    'it' => '(#10) string with spaces and single quotes',
    'it_result' => {
      'windows' => "wraps in double quotes and leaves single quotes",
      'other'   => 'escapes the single quotes and spaces with <backslash>'
    },
    'str' => "string with spaces and 'single' quotes",
    'expect' => {
      'windows' => "\"string with spaces and 'single' quotes\"",
      'other'   => 'string\ with\ spaces\ and\ \\\'single\\\'\ quotes'
    }
  },
  {
    'it' => '(#11) string with spaces and <backslash>',
    'it_result' => {
      'windows' => "wraps in double quotes and escapes the backslash with backslash",
      'other'   => 'escapes the spaces and the backslash (which in results in quite a lot of them)'
    },
    'str' => "string with spaces and \\ in it",
    'expect' => {
      'windows' => "\"string with spaces and \\ in it\"",
      'other'   => "string\\ with\\ spaces\\ and\\ \\\\\\ in\\ it"
    }
  },
  {
    'it' => '(#12) string with spaces and <slash>',
    'it_result' => {
      'windows' => "wraps in double quotes",
      'other'   => 'escapes the spaces'
    },
    'str' => "string with spaces and / in it",
    'expect' => {
      'windows' =>  "\"string with spaces and / in it\"",
      'other'   => "string\\ with\\ spaces\\ and\\ /\\ in\\ it"
    }
  },
  {
    'it' => '(#13) string with spaces and parens',
    'it_result' => {
      'windows' => "wraps in double quotes",
      'other'   => 'escapes the spaces and parens'
    },
    'str' => "string with spaces and (parens) in it",
    'expect' => {
      'windows' => "\"string with spaces and (parens) in it\"",
      'other'   => "string\\ with\\ spaces\\ and\\ \\(parens\\)\\ in\\ it"
    }
  },
  {
    'it' => '(#14) string with spaces, single quotes and parens',
    'it_result' => {
      'windows' => "wraps in double quotes",
      'other'   => 'escapes the spaces, single quotes and parens'
    },
    'str' => "string with spaces and 'quotes' (and parens) in it",
    'expect' => {
      'windows' => "\"string with spaces and 'quotes' (and parens) in it\"",
      'other'   => "string\\ with\\ spaces\\ and\\ \\'quotes\\'\\ \\(and\\ parens\\)\\ in\\ it"
    }
  }
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

# confirms that the escaped string that is generated actually
# gets turned back into the source string by the actual shell.
# abuses a `grep` (or `find`) error message because that should be cross platform
def confirm_shell_unescapes_string_correctly(string, escaped)
  compare_string = string.to_s.dup

  if FastlaneCore::CommandExecutor.which('grep')
    if FastlaneCore::Helper.windows?
      compare_string = simulate_windows_shell_unwrapping(compare_string)
    else
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

# remove (double and single) quote pairs
# un-double-double quote resulting string
def simulate_windows_shell_unwrapping(string)
  regex = /^("|')(([^"])(\S*)([^"]))("|')$/
  unless string.to_s.match(regex).nil?
    string = string.to_s.match(regex)[2] # get only part in quotes
    string.to_s.gsub!('""', '"') # remove doubled double quotes
  end
  return string
end

# remove all double quotes completely
def simulate_normal_shell_unwrapping(string)
  string.gsub!('"', '')
  regex = /^(')(\S*)(')$/
  unless string.to_s.match(regex).nil?
    string = string.to_s.match(regex)[2] # get only part in quotes
  end
  return string
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
        expect_correct_implementation_to_be_called(str, :shellescape, os)
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
        expect_correct_implementation_to_be_called(str, :shellescape, os)
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
    'it' => '(#4) on array with entry that is `$$`',
    'it_result' => {
      'windows' => 'the result includes the process id',
      'other'   => 'the result includes the process id'
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
        expect_correct_implementation_to_be_called(array, :shelljoin, os)
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
        expect_correct_implementation_to_be_called(array, :shelljoin, os)
        joined = array.shelljoin
        expect(joined).to eq(testcase['expect'][os])
      end
    end
  end
end

def expect_correct_implementation_to_be_called(obj, method, os)
  if method == :shellescape
    # String.shellescape => CrossplatformShellwords.shellescape => ...
    expect(obj).to receive(:shellescape).and_call_original
    expect(CrossplatformShellwords).to receive(:shellescape).with(obj).and_call_original
    if os == 'windows'
      # WindowsShellwords.shellescape
      expect(WindowsShellwords).to receive(:shellescape).with(obj).and_call_original
      expect(Shellwords).not_to(receive(:escape))
    else
      # Shellwords.escape
      expect(Shellwords).to receive(:escape).with(obj).and_call_original
      expect(WindowsShellwords).not_to(receive(:shellescape))
    end
  elsif method == :shelljoin
    # Array.shelljoin => CrossplatformShellwords.shelljoin => CrossplatformShellwords.shellescape ...
    expect(obj).to receive(:shelljoin).and_call_original
    expect(CrossplatformShellwords).to receive(:shelljoin).with(obj).and_call_original
    expect(CrossplatformShellwords).to receive(:shellescape).at_least(:once).and_call_original
  end
end
