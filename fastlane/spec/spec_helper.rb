Fastlane.load_actions

def before_each_fastlane
  Fastlane::Actions.clear_lane_context

  ENV.delete('DELIVER_SCREENSHOTS_PATH')
  ENV.delete('DELIVER_SKIP_BINARY')
  ENV.delete('DELIVER_VERSION')
end

# Runs a command in a fixture project's own bundle, out of process. The bundle reuses the
# gems installed for this repository and installs with --local, so nothing is fetched.
def run_in_fixture_bundle(fixture_path, command)
  require "open3"
  bundle_path = Bundler.configured_bundle_path
  # Absolute, as the checked-in path is relative to this repository, not to the fixture
  env = bundle_path.use_system_gems? ? {} : { "BUNDLE_PATH" => Bundler.root.join(bundle_path.base_path).to_s }
  # The child is a real fastlane run, out of reach of spec_helper's stubs: without this it sends an
  # analytics event and records that it showed the notice in ~/.fastlane. See fastlane#30187.
  env["FASTLANE_OPT_OUT_USAGE"] = "1"
  Bundler.with_unbundled_env do
    Dir.chdir(fixture_path) do
      install_output, status = Open3.capture2e(env, "bundle install --local")
      raise "bundle install --local failed in #{fixture_path}:\n#{install_output}" unless status.success?
      Open3.capture2e(env, "bundle exec #{command}").first
    end
  end
end

# Creates `App.xcodeproj` with one app target in the given directory and returns its path. The
# build settings go into the target's build configurations. An Info.plist, when given, is written
# next to the project and set as the target's INFOPLIST_FILE. The block can change the project
# before it is saved.
def create_versioning_project(dir, build_settings: {}, info_plist: nil)
  require "xcodeproj"
  project = Xcodeproj::Project.new(File.join(dir, "App.xcodeproj"))
  target = project.new_target(:application, "App", :ios)
  if info_plist
    Xcodeproj::Plist.write_to_path(info_plist, File.join(dir, "Info.plist"))
    build_settings = build_settings.merge("INFOPLIST_FILE" => "Info.plist")
  end
  target.build_configurations.each { |config| config.build_settings.merge!(build_settings) }
  yield(project, target) if block_given?
  project.save
  project.path.to_s
end

# Returns the values of a build setting in the target's build configurations of a saved project.
def versioning_project_build_settings(project_path, build_setting)
  Xcodeproj::Project.open(project_path).targets.first.build_configurations.map { |config| config.build_settings[build_setting] }
end

def stub_plugin_exists_on_rubygems(plugin_name, exists)
  stub_request(:get, "https://rubygems.org/api/v1/gems/fastlane-plugin-#{plugin_name}.json").
    with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
    to_return(status: 200, body: (exists ? { version: "1.0" }.to_json : nil), headers: {})
end
