# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require "coveralls"
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require "webmock/rspec"
WebMock.disable_net_connect!(allow: 'coveralls.io')

require "fastlane"
require "tmpdir"
UI = FastlaneCore::UI

# Spaceship persists a session cookie to ~/.fastlane/spaceship/<user>/cookie,
# under the real home directory, and reads it back to decide whether a session
# is valid. That makes the suite write to the developer's machine, and it makes
# a spec able to depend on a file some earlier run left behind: the cookie four spaceauth
# examples depended on was nine months older than the run that needed it here, so
# they passed locally in every order and failed only on a clean checkout. Redirect the store
# to a temporary directory that belongs to this process, so the suite leaves
# nothing behind and a spec needing a session has to arrange one itself.
#
# See fastlane#30184.
SPACESHIP_COOKIE_DIR = Dir.mktmpdir("fastlane-spec-spaceship")
ENV["SPACESHIP_COOKIE_PATH"] = SPACESHIP_COOKIE_DIR

unless ENV["DEBUG"]
  fastlane_tests_tmpdir = "#{Dir.tmpdir}/fastlane_tests"
  $stdout.puts("Changing stdout to #{fastlane_tests_tmpdir}, set `DEBUG` environment variable to print to stdout (e.g. when using `pry`)")
  $stdout = File.open(fastlane_tests_tmpdir, "w")
end

if FastlaneCore::Helper.mac?
  xcode_path = FastlaneCore::Helper.xcode_path
  unless xcode_path.include?("Contents/Developer")
    UI.error("Seems like you didn't set the developer tools path correctly")
    UI.error("Detected path '#{xcode_path}'") if xcode_path.to_s.length > 0
    UI.error("Please run the following on your machine")
    UI.command("sudo xcode-select -s /Applications/Xcode.app")
    UI.error("Adapt the path if you have Xcode installed/named somewhere else")
    exit(1)
  end
end

(Fastlane::TOOLS + [:spaceship, :fastlane_core]).each do |tool|
  path = File.join(tool.to_s, "spec", "spec_helper.rb")
  require_relative path if File.exist?(path)
  require tool.to_s
end

my_main = self
RSpec.configure do |config|
  # Singleton guard, see fastlane#30184.
  #
  # The fastlane tools keep their configuration on the module itself, so a value
  # one example assigns is still there for every example after it. Four rows of
  # internal/order_dependent_specs.md are the same defect: a group reading
  # configuration it never set, green only while something earlier happened to
  # leave one behind. Row W survived roughly twenty five random orders before a
  # seed caught it, so waiting for seeds to find the rest is slow.
  #
  # Clearing them after every example turns those from occasional failures into
  # permanent ones, which is the only way to enumerate them rather than wait.
  #
  # The ivars are cleared rather than assigned through the writers: Scan, Gym
  # and Snapshot define `config=` to run detection and reset their cache as a
  # side effect, so assigning nil would run detection against a nil config.
  #
  # FASTLANE_SPEC_SINGLETON_GUARD=off restores the old behaviour.
  SINGLETON_GUARD_MODE = (ENV["FASTLANE_SPEC_SINGLETON_GUARD"] || "reset").to_sym

  # Read off the `class << self` blocks of each tool's module.rb, plus
  # supply/lib/supply.rb, which keeps its accessor elsewhere.
  SINGLETON_ACCESSORS = {
    "Cert" => %i[config],
    "Deliver" => %i[cache],
    "Frameit" => %i[config],
    "Gym" => %i[config project cache],
    "PEM" => %i[config],
    "Precheck" => %i[config],
    "Produce" => %i[config],
    "Scan" => %i[config project cache devices],
    "Screengrab" => %i[config android_environment],
    "Sigh" => %i[config],
    "Snapshot" => %i[config project cache],
    "Supply" => %i[config]
  }.freeze

  config.after(:each) do
    next if SINGLETON_GUARD_MODE == :off

    SINGLETON_ACCESSORS.each do |name, attributes|
      next unless Object.const_defined?(name)

      mod = Object.const_get(name)
      attributes.each { |attribute| mod.instance_variable_set("@#{attribute}", nil) }
    end
  end

  config.after(:suite) do
    FileUtils.remove_entry(SPACESHIP_COOKIE_DIR) if File.directory?(SPACESHIP_COOKIE_DIR)
  end

  config.before(:each) do |current_test|
    # We don't want to call the RubyGems API at any point
    # This was a request that was added with Ruby 2.4.0
    allow(Fastlane::FastlaneRequire).to receive(:install_gem_if_needed).and_return(nil)

    ENV['FASTLANE_PLATFORM_NAME'] = nil

    # execute `before_each_*` method from spec_helper for each tool
    tool_name = current_test.id.match(%r{\.\/(\w+)\/})[1]
    method_name = "before_each_#{tool_name}".to_sym
    begin
      my_main.send(method_name)
    rescue NoMethodError
      # no method implemented
    end

    # Make sure PATH didn't get emptied during execution of previous (!) test
    expect(ENV['PATH']).to be_truthy, "PATH is missing. (Previous test probably emptied it.)"
  end

  config.after(:each) do |current_test|
    # execute `after_each_*` method from spec_helper for each tool
    tool_name = current_test.id.match(%r{\.\/(\w+)\/})[1]
    method_name = "after_each_#{tool_name}".to_sym
    begin
      my_main.send(method_name)
    rescue NoMethodError
      # no method implemented
    end
  end

  config.example_status_persistence_file_path = "#{Dir.tmpdir}/rspec_failed_tests.txt"

  # skip some tests if not running on mac
  unless FastlaneCore::Helper.mac?

    # define metadata tags that also imply :skip
    config.define_derived_metadata(:requires_xcode) do |meta|
      meta[:skip] = "Skipped: Requires Xcode to be installed (which is not possible on this platform and no workaround has been implemented)"
    end
    config.define_derived_metadata(:requires_xcodebuild) do |meta|
      meta[:skip] = "Skipped: Requires `xcodebuild` to be installed (which is not possible on this platform and no workaround has been implemented)"
    end
    config.define_derived_metadata(:requires_plistbuddy) do |meta|
      meta[:skip] = "Skipped: Requires `plistbuddy` to be installed (which is not possible on this platform and no workaround has been implemented)"
    end
    config.define_derived_metadata(:requires_keychain) do |meta|
      meta[:skip] = "Skipped: Requires `keychain` to be installed (which is not possible on this platform and no workaround has been implemented)"
    end
    config.define_derived_metadata(:requires_security) do |meta|
      meta[:skip] = "Skipped: Requires `security` to be installed (which is not possible on this platform and no workaround has been implemented)"
    end

    # also skip `before()` for test groups that are skipped because of their tags.
    # only works for `describe` groups (that are parents of the `before`, not if the tag is set on `it`.
    # caution: has unexpected side effect on usage of `skip: false` for individual examples,
    # see https://groups.google.com/d/msg/rspec/5qeKQr_7G7k/Pb3ss2hOAAAJ
    module HookOverrides
      def before(*args)
        super unless metadata[:skip]
      end
    end
    config.extend(HookOverrides)

  end

  # skip some more tests if run on on Windows
  if FastlaneCore::Helper.windows? || !system('which xar')
    config.define_derived_metadata(:requires_xar) do |meta|
      meta[:skip] = "Skipped: Requires `xar` to be installed (which is not possible on Windows and some Linux distros and no workaround has been implemented)"
    end
  end

  if FastlaneCore::Helper.windows?
    config.define_derived_metadata(:requires_pty) do |meta|
      meta[:skip] = "Skipped: Requires `pty` to be available (which is not possible on Windows and no workaround has been implemented)"
    end
  end
end

module FastlaneSpec
  module Env
    # a wrapper to temporarily modify the values of ARGV to
    # avoid errors like: "warning: already initialized constant ARGV"
    # if no block is given, modifies ARGV for good
    # rubocop:disable Naming/MethodName
    def self.with_ARGV(argv)
      copy = ARGV.dup
      ARGV.clear
      ARGV.concat(argv)
      # Commander::Methods imports delegate methods that shares the singleton
      # so this prevents Commander from choosing wrong command previously cached.
      Commander::Runner.instance_variable_set(:@instance, nil)
      begin
        # Do not check for "block_given?". This method is useless without a
        # block, and must fail if used like that.
        yield
      ensure
        ARGV.clear
        ARGV.concat(copy)
      end
    end
    # rubocop:enable Naming/MethodName

    def self.with_verbose(verbose)
      orig_verbose = FastlaneCore::Globals.verbose?
      FastlaneCore::Globals.verbose = verbose
      # Do not check for "block_given?". This method is useless without a
      # block, and must fail if used like that.
      yield
    ensure
      FastlaneCore::Globals.verbose = orig_verbose
    end

    # Executes the provided block after adjusting the ENV to have the
    # provided keys and values set as defined in hash. After the block
    # completes, restores the ENV to its previous state.
    require "climate_control"
    def self.with_env_values(hash, &block)
      ClimateControl.modify(hash, &block)
    end

    def self.with_action_context_values(hash, &block)
      with_global_key_values(Fastlane::Actions.lane_context, hash, &block)
    end

    def self.with_global_key_values(global_store, hash)
      old_vals = global_store.select { |k, v| hash.include?(k) }
      hash.each { |k, v| global_store[k] = v }
      yield
    ensure
      hash.each do |k, v|
        if old_vals.include?(k)
          global_store[k] = old_vals[k]
        else
          global_store.delete(k)
        end
      end
    end
  end
end
