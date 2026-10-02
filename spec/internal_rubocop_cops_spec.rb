require "rubocop"
require "rubocop/rspec/support"
require_relative "../internal/rubocop/fork_usage"
require_relative "../internal/rubocop/is_string_usage"
require_relative "../internal/rubocop/missing_keys_on_shared_area"
require_relative "../internal/rubocop/unescaped_shell_interpolation"

describe "fastlane's own RuboCop cops" do
  include RuboCop::RSpec::ExpectOffense

  let(:config) { RuboCop::Config.new }
  let(:cop) { described_class.new(config) }

  [RuboCop::CrossPlatform::ForkUsage, RuboCop::Cop::Lint::IsStringUsage, RuboCop::Lint::MissingKeysOnSharedArea, RuboCop::Cop::Fastlane::UnescapedShellInterpolation].each do |cop_class|
    it "builds #{cop_class} on the cop API RuboCop does not deprecate, see #30301" do
      expect(cop_class.ancestors).not_to include(RuboCop::Cop::Cop)
    end
  end

  describe RuboCop::CrossPlatform::ForkUsage do
    it "flags fork" do
      expect_offense(<<~RUBY)
        fork
        ^^^^ CrossPlatform/ForkUsage: Using `fork`, which does not work on all platforms. Wrap in `if Process.respond_to?(:fork)` to silence.
      RUBY
    end

    it "accepts a fork guarded by Process.respond_to?" do
      expect_no_offenses(<<~RUBY)
        if Process.respond_to?(:fork)
          fork
        end
      RUBY
    end
  end

  describe RuboCop::Cop::Lint::IsStringUsage do
    it "flags is_string in a ConfigItem" do
      expect_offense(<<~RUBY)
        FastlaneCore::ConfigItem.new(key: :a, is_string: true)
                                              ^^^^^^^^^^^^^^^ Lint/IsStringUsage: is_string key in used in FastlaneCore::ConfigItem. Replace with `type: <Integer|Float|String|Boolean|Array|Hash>`
      RUBY
    end

    it "accepts type" do
      expect_no_offenses(<<~RUBY)
        FastlaneCore::ConfigItem.new(key: :a, type: Boolean)
      RUBY
    end
  end

  describe RuboCop::Lint::MissingKeysOnSharedArea do
    it "flags setting a SharedValues key that is not declared" do
      expect_offense(<<~RUBY)
        lane_context[SharedValues::BAR] = 1
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Lint/MissingKeysOnSharedArea: Found setting a value for `SharedValues` in a function but the const is not declared in `SharedValues` module
      RUBY
    end

    it "accepts setting a declared SharedValues key" do
      expect_no_offenses(<<~RUBY)
        module SharedValues
          BAR = :BAR
        end
        lane_context[SharedValues::BAR] = 1
      RUBY
    end
  end

  describe RuboCop::Cop::Fastlane::UnescapedShellInterpolation do
    it "flags an unescaped value in sh" do
      expect_offense(<<~'RUBY')
        sh("git tag #{tag}")
                    ^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `tag` (`.shellescape`), or pass the command as separate arguments.
      RUBY
    end

    it "flags an unescaped value in backticks and Open3" do
      expect_offense(<<~'RUBY')
        `ls #{path}`
            ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `path` (`.shellescape`), or pass the command as separate arguments.
        Open3.capture3("ls #{path}")
                           ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `path` (`.shellescape`), or pass the command as separate arguments.
      RUBY
    end

    it "points at Open3 for a redirect, which separate arguments cannot express" do
      expect_offense(<<~'RUBY')
        sh("cmd #{arg1} #{arg2} 2>/dev/null")
                ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `arg1` (`.shellescape`), or run it without a shell: for the redirect, Open3 with `out:`/`err:` (`err: File::NULL`), or `Open3.capture2e` for `2>&1`.
                        ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `arg2` (`.shellescape`), or run it without a shell: for the redirect, Open3 with `out:`/`err:` (`err: File::NULL`), or `Open3.capture2e` for `2>&1`.
      RUBY
    end

    it "points at Open3 for a pipe" do
      expect_offense(<<~'RUBY')
        sh("cmd1 #{arg1} | cmd2 #{arg2}")
                 ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `arg1` (`.shellescape`), or run it without a shell: for the pipe, `Open3.pipeline_r`, or filter the output in Ruby.
                                ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `arg2` (`.shellescape`), or run it without a shell: for the pipe, `Open3.pipeline_r`, or filter the output in Ruby.
      RUBY
    end

    it "points at one call per command for && and ||, which are not pipes" do
      expect_offense(<<~'RUBY')
        sh("cd #{dir} && make || true")
               ^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `dir` (`.shellescape`), or run it without a shell: for `&&`/`;`, one call per command (`chdir:` replaces `cd … &&`).
      RUBY
    end

    it "lists every shell feature the command uses" do
      expect_offense(<<~'RUBY')
        `cmd1 #{arg} 2>&1 | cmd2`
              ^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `arg` (`.shellescape`), or run it without a shell: for the pipe, `Open3.pipeline_r`, or filter the output in Ruby; for the redirect, Open3 with `out:`/`err:` (`err: File::NULL`), or `Open3.capture2e` for `2>&1`.
      RUBY
    end

    it "ignores shell characters inside quotes" do
      expect_offense(<<~'RUBY')
        sh("git log --format='%h > %s' #{ref}")
                                       ^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `ref` (`.shellescape`), or pass the command as separate arguments.
      RUBY
    end

    it "reads a command continued over several lines" do
      expect_offense(<<~'RUBY')
        sh("cmd1 #{arg} | " \
                 ^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `arg` (`.shellescape`), or run it without a shell: for the pipe, `Open3.pipeline_r`, or filter the output in Ruby; for the redirect, Open3 with `out:`/`err:` (`err: File::NULL`), or `Open3.capture2e` for `2>&1`.
           "cmd2 2>/dev/null")
      RUBY
    end

    it "accepts escaped values in a pipe or a redirect" do
      expect_no_offenses(<<~'RUBY')
        sh("cmd #{arg1.shellescape} #{arg2.shellescape} 2>/dev/null")
        sh("cmd1 #{arg1.shellescape} | cmd2 #{arg2.shellescape}")
      RUBY
    end

    it "accepts escaped values, numbers and separate arguments" do
      expect_no_offenses(<<~'RUBY')
        sh("git tag #{tag.shellescape}")
        sh("ls #{Shellwords.escape(path)}")
        sh("ls #{paths.shelljoin}")
        sh("sleep #{seconds.to_i}")
        sh("git", "tag", tag)
      RUBY
    end

    it "accepts a list escaped item by item" do
      expect_no_offenses(<<~'RUBY')
        sh("ls #{paths.map(&:shellescape).join(' ')}")
        sh("ls #{paths.map { |p| p.shellescape }.join(' ')}")
      RUBY
    end

    it "flags a list joined without escaping" do
      expect_offense(<<~'RUBY')
        sh("ls #{paths.map(&:to_s).join(' ')}")
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `paths.map(&:to_s).join(' ')` (`.shellescape`), or pass the command as separate arguments.
      RUBY
    end

    it "accepts a variable whose every assignment is escaped, also from a block" do
      expect_no_offenses(<<~'RUBY')
        def run(path)
          escaped = path.shellescape
          [1].each { sh("ls #{escaped}") }
        end
      RUBY
    end

    it "only follows assignments in the same method" do
      expect_no_offenses(<<~'RUBY')
        def other(path)
          escaped = path
        end

        def run(path)
          escaped = path.shellescape
          sh("ls #{escaped}")
        end
      RUBY
    end

    it "flags a variable that is also assigned unescaped, or changed with +=" do
      expect_offense(<<~'RUBY')
        def run(path)
          a = path.shellescape
          a = path if other
          sh("ls #{a}")
                 ^^^^ Fastlane/UnescapedShellInterpolation: Escape `a` (`.shellescape`), or pass the command as separate arguments.
          b = path.shellescape
          b += "x"
          sh("ls #{b}")
                 ^^^^ Fastlane/UnescapedShellInterpolation: Escape `b` (`.shellescape`), or pass the command as separate arguments.
        end
      RUBY
    end

    it "flags a method argument" do
      expect_offense(<<~'RUBY')
        def run(path)
          sh("ls #{path}")
                 ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `path` (`.shellescape`), or pass the command as separate arguments.
        end
      RUBY
    end

    it "checks a command built in a variable where it is built" do
      expect_offense(<<~'RUBY')
        def run(path)
          command = "security import #{path}"
                                     ^^^^^^^ Fastlane/UnescapedShellInterpolation: Escape `path` (`.shellescape`), or pass the command as separate arguments.
          sh(command)
        end
      RUBY
    end
  end
end
