# This module is only used to check the environment is currently a testing env
module SpecHelper
end

require "coveralls"
Coveralls.wear! unless ENV["FASTLANE_SKIP_UPDATE_CHECK"]

require "webmock/rspec"
WebMock.disable_net_connect!(allow: 'coveralls.io')

require "fastlane"
UI = FastlaneCore::UI

unless ENV["DEBUG"]
  fastlane_tests_tmpdir = "#{Dir.tmpdir}/fastlane_tests"
  $stdout.puts("Changing stdout to #{fastlane_tests_tmpdir}, set `DEBUG` environment variable to print to stdout (e.g. when using `pry`)")
  $stdout = File.open(fastlane_tests_tmpdir, "w")
end

# FastlaneCore::Shell prints "Logging disabled while running tests" the first
# time anything touches the logger, and memoises it, so whichever example gets
# there first absorbs the banner. An example asserting on its own stdout then
# fails or passes depending on what ran before it. Emit it here instead, while
# stdout is the redirect above rather than an example's capture. See
# fastlane#30184.
FastlaneCore::UI.ui_object.log

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

# A tool spec helper that writes to ENV at the top level rather than from a
# before_each_* method would do it once, outside every example, where the guard
# below can neither blame an example for it nor restore it. Nothing does that
# today; this is here so that it cannot start silently. See fastlane#30184.
env_guard_pristine = ENV.to_h

(Fastlane::TOOLS + [:spaceship, :fastlane_core]).each do |tool|
  path = File.join(tool.to_s, "spec", "spec_helper.rb")
  require_relative path if File.exist?(path)
  require tool.to_s
end

env_guard_loaded = ENV.to_h
ENV_GUARD_LOAD_TIME = ((env_guard_loaded.keys - env_guard_pristine.keys) |
                       (env_guard_pristine.keys - env_guard_loaded.keys) |
                       (env_guard_loaded.keys & env_guard_pristine.keys)
                         .reject { |key| env_guard_loaded[key] == env_guard_pristine[key] }).sort.freeze

my_main = self
RSpec.configure do |config|
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

  # Environment guard, see fastlane#30184.
  #
  # A test that leaves a variable behind changes what every later test in the
  # process sees, and several of the ones involved carry credentials:
  # DELIVER_PASSWORD, FASTLANE_PASSWORD and FASTLANE_SESSION have all been found
  # leaking between examples. Tests should scope what they set with
  # FastlaneSpec::Env.with_env_values rather than assigning to ENV directly.
  #
  # Modes, through FASTLANE_SPEC_ENV_GUARD:
  #   enforce (default) restore ENV after each example, and report what escaped
  #   report            leave ENV alone, report what escaped
  #   off               do nothing
  #
  # Restoring is what makes the report worth reading. Without it each example is
  # measured against whatever the previous one left behind, so an example setting
  # a variable to the value already leaked there registers no change and is never
  # named. Three specs set DELIVER_PASSWORD to "123": running those files in
  # report mode names one example, enforce mode names all 64. The set of keys is
  # the same either way, the attribution is not, and in report mode it depends
  # entirely on the order the suite happened to run in.
  #
  # An example that is meant to leave something behind declares it:
  #   it "sets the team id", env_output: %w[FASTLANE_TEAM_ID] do
  #
  # Two kinds of write are invisible here because both happen outside
  # around(:each): top level writes in a tool spec helper, reported separately
  # from ENV_GUARD_LOAD_TIME below, and writes in a before(:context) hook, which
  # enter the baseline of every example in the group and outlive the group.
  #
  # FASTLANE_SPEC_ENV_GUARD_REPORT names a file to write the full inventory to.
  # The console summary lists only the first few examples per variable, which is
  # not enough to work from when a variable has a thousand of them.
  #
  # Only key names are ever reported. The values are the point of the exercise.
  ENV_GUARD_MODE = (ENV["FASTLANE_SPEC_ENV_GUARD"] || "enforce").to_sym
  ENV_GUARD_LEAKS = Hash.new { |hash, key| hash[key] = [] }
  ENV_GUARD_REPORT_PATH = ENV["FASTLANE_SPEC_ENV_GUARD_REPORT"]

  config.around(:each) do |example|
    if ENV_GUARD_MODE == :off
      example.run
    else
      before = ENV.to_h
      begin
        example.run
      ensure
        allowed = Array(example.metadata[:env_output]).map(&:to_s)
        after = ENV.to_h
        escaped = ((after.keys - before.keys) | (before.keys - after.keys) |
                   (before.keys & after.keys).reject { |key| before[key] == after[key] }) - allowed
        escaped.each { |key| ENV_GUARD_LEAKS[key] << example.id }
        ENV.replace(before) if ENV_GUARD_MODE == :enforce
      end
    end
  end

  config.after(:suite) do
    unless ENV_GUARD_LOAD_TIME.empty?
      warn("")
      warn("[env-guard] #{ENV_GUARD_LOAD_TIME.size} variables were set while the tool spec helpers loaded.")
      warn("[env-guard] They are written outside any example, so no mode restores them and no example is blamed.")
      warn("[env-guard] Move them into a hook to bring them under the guard: #{ENV_GUARD_LOAD_TIME.join(', ')}")
    end

    next if ENV_GUARD_LEAKS.empty?

    ranked = ENV_GUARD_LEAKS.sort_by { |key, ids| [-ids.size, key] }

    warn("")
    warn("[env-guard] #{ENV_GUARD_LEAKS.size} environment variables escaped the example that changed them.")
    warn("[env-guard] Scope them with FastlaneSpec::Env.with_env_values, or declare them with env_output:.")
    warn("[env-guard] Reporting only, ENV was left as the examples made it.") if ENV_GUARD_MODE == :report
    ranked.each do |key, ids|
      warn("[env-guard]   #{key} (#{ids.size})")
      ids.uniq.first(3).each { |id| warn("[env-guard]       #{id}") }
      warn("[env-guard]       ...") if ids.uniq.size > 3
    end

    if ENV_GUARD_REPORT_PATH
      File.open(ENV_GUARD_REPORT_PATH, "w") do |file|
        file.puts("# fastlane#30184, environment guard, mode #{ENV_GUARD_MODE}")
        file.puts("# set while the tool spec helpers loaded: #{ENV_GUARD_LOAD_TIME.join(', ')}") unless ENV_GUARD_LOAD_TIME.empty?
        ranked.each do |key, ids|
          file.puts("")
          file.puts("#{key} (#{ids.uniq.size})")
          ids.uniq.sort.each { |id| file.puts("  #{id}") }
        end
      end
      warn("[env-guard] Full inventory written to #{ENV_GUARD_REPORT_PATH}")
    end
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
