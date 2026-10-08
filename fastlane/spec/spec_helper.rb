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
  env = bundle_path.use_system_gems? ? {} : { "BUNDLE_PATH" => bundle_path.base_path.to_s }
  Bundler.with_unbundled_env do
    Dir.chdir(fixture_path) do
      install_output, status = Open3.capture2e(env, "bundle install --local")
      raise "bundle install --local failed in #{fixture_path}:\n#{install_output}" unless status.success?
      Open3.capture2e(env, "bundle exec #{command}").first
    end
  end
end

def stub_plugin_exists_on_rubygems(plugin_name, exists)
  stub_request(:get, "https://rubygems.org/api/v1/gems/fastlane-plugin-#{plugin_name}.json").
    with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
    to_return(status: 200, body: (exists ? { version: "1.0" }.to_json : nil), headers: {})
end
