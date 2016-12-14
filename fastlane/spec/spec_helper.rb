unless ENV["DEBUG"]
  $stdout = File.open("/tmp/spaceship_tests", "w")
end

require 'shellwords'

Fastlane.load_actions

def before_each_fastlane
  Fastlane::Actions.clear_lane_context

  ENV.delete 'DELIVER_SCREENSHOTS_PATH'
  ENV.delete 'DELIVER_SKIP_BINARY'
  ENV.delete 'DELIVER_VERSION'
end

def with_verbose(verbose)
  orig_verbose = $verbose
  $verbose = verbose
  yield if block_given?
ensure
  $verbose = orig_verbose
end

def stub_plugin_exists_on_rubygems(plugin_name, exists)
  stub_request(:get, "https://rubygems.org/api/v1/gems/fastlane-plugin-#{plugin_name}.json").
    with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
    to_return(status: 200, body: (exists ? { version: "1.0" }.to_json : nil), headers: {})
end
