require "rubocop"
require "rubocop/rspec/support"
require_relative "../internal/rubocop/fork_usage"
require_relative "../internal/rubocop/is_string_usage"
require_relative "../internal/rubocop/missing_keys_on_shared_area"

describe "fastlane's own RuboCop cops" do
  include RuboCop::RSpec::ExpectOffense

  let(:config) { RuboCop::Config.new }
  let(:cop) { described_class.new(config) }

  [RuboCop::CrossPlatform::ForkUsage, RuboCop::Cop::Lint::IsStringUsage, RuboCop::Lint::MissingKeysOnSharedArea].each do |cop_class|
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
end
