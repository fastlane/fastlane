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
      raise "bundle install --local failed in #{fixture_path}:\n#{install_output}#{fixture_bundle_diagnostics(install_output, env)}" unless status.success?
      Open3.capture2e(env, "bundle exec #{command}").first
    end
  end
end

# Details for a failed fixture install, to explain an EACCES on fastlane.bat seen now and then on Windows CI. See fastlane#30668.
def fixture_bundle_diagnostics(install_output, env)
  lines = ["", "--- diagnostics ---"]
  path = install_output[/rb_sysopen - (\S+)/, 1]
  if path && File.exist?(path)
    stat = File.stat(path)
    lines << "#{path}: #{stat.size} bytes, modified #{stat.mtime.utc}"
    lines << Open3.capture2e("attrib", path.tr("/", "\\")).first.strip if Gem.win_platform?
  end
  if Gem.win_platform?
    processes = "Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -match 'fastlane' } | " \
                "ForEach-Object { \"$($_.ProcessId) (parent $($_.ParentProcessId)): $($_.CommandLine)\" }"
    lines << "processes mentioning fastlane:\n#{Open3.capture2e('powershell', '-NoProfile', '-Command', processes).first.strip}"
  end
  sleep(1)
  retry_output, retry_status = Open3.capture2e(env, "bundle install --local")
  lines << "the same install 1 s later: #{retry_status.success? ? 'succeeded' : "failed:\n#{retry_output}"}"
  lines.join("\n")
rescue StandardError => e
  "\n--- diagnostics failed: #{e.class}: #{e.message}"
end

def stub_plugin_exists_on_rubygems(plugin_name, exists)
  stub_request(:get, "https://rubygems.org/api/v1/gems/fastlane-plugin-#{plugin_name}.json").
    with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
    to_return(status: 200, body: (exists ? { version: "1.0" }.to_json : nil), headers: {})
end
