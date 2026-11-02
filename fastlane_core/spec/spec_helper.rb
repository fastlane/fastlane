require_relative 'test_commander_program'

# Necessary, as we're now running this in a different context
def stub_request(*args)
  WebMock::API.stub_request(*args)
end

def stub_commander_runner_args(args)
  runner = Commander::Runner.new(args)
  allow(Commander::Runner).to receive(:instance).and_return(runner)
end

def capture_stds
  require "stringio"
  orig_stdout = $stdout
  orig_stderr = $stderr
  $stdout = StringIO.new
  $stderr = StringIO.new
  yield if block_given?
  [$stdout.string, $stderr.string]
ensure
  $stdout = orig_stdout
  $stderr = orig_stderr
end

# Yields the path of a temporary copy of a checked-in fixture, file or
# directory, for specs whose code writes to what it reads: parallel workers
# share the checkout.
def with_fixture_copy(path)
  Dir.mktmpdir("fl_spec_fixture") do |dir|
    FileUtils.cp_r(path, dir)
    yield(File.join(dir, File.basename(path)))
  end
end

# Build settings that are paths on the machine that answered; a faked project
# answers them as unset.
MACHINE_PATH_BUILD_SETTINGS = %w[BUILT_PRODUCTS_DIR SDKROOT].freeze

# Fetching build settings runs xcodebuild twice, over a second each time;
# fake it out for tests that do not check a build setting.
# settings maps a project path and scheme to the keys xcodebuild
# -showBuildSettings answers for them. A project, scheme or key not listed
# keeps the real lookup.
def fake_out_build_settings(settings)
  settings = settings.transform_keys { |path| File.expand_path(path) }
  allow_any_instance_of(FastlaneCore::Project).to receive(:build_settings).and_wrap_original do |original, key: nil, optional: true|
    project = original.receiver
    answers = settings.dig(project.path, project.options[:scheme])
    next nil if answers && MACHINE_PATH_BUILD_SETTINGS.include?(key)
    next original.call(key: key, optional: optional) unless answers&.key?(key)

    answers[key]
  end
end

# Checks a fake_out_build_settings table against the installed Xcode.
def expect_build_settings_to_match_xcode(settings)
  allow_any_instance_of(FastlaneCore::Project).to receive(:build_settings).and_call_original
  settings.each do |path, schemes|
    schemes.each do |scheme, answers|
      location = path.end_with?(".xcworkspace") ? :workspace : :project
      project = FastlaneCore::Project.new(location => path, scheme: scheme)
      answers.each do |key, value|
        expect(project.build_settings(key: key)).to eq(value), "#{path} #{scheme} #{key}"
      end
    end
  end
end
