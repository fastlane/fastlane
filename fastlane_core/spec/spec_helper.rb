require_relative 'test_commander_program'

# Necessary, as we're now running this in a different context
def stub_request(*args)
  WebMock::API.stub_request(*args)
end

def before_each_fastlane_core
  # iTunes Lookup API by Apple ID
  ["invalid", "", 0, '284882215', ['338986109', 'FR']].each do |current|
    if current.kind_of?(Array)
      id = current[0]
      country = current[1]
      url = "https://itunes.apple.com/lookup?id=#{id}&country=#{country}"
      body_file = "fastlane_core/spec/responses/itunesLookup-#{id}_#{country}.json"
    else
      id = current
      url = "https://itunes.apple.com/lookup?id=#{id}"
      body_file = "fastlane_core/spec/responses/itunesLookup-#{id}.json"
    end
    stub_request(:get, url).
      with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
      to_return(status: 200, body: File.read(body_file), headers: {})
  end

  # iTunes Lookup API by App Identifier
  stub_request(:get, "https://itunes.apple.com/lookup?bundleId=com.facebook.Facebook").
    with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
    to_return(status: 200, body: File.read("fastlane_core/spec/responses/itunesLookup-com.facebook.Facebook.json"), headers: {})

  stub_request(:get, "https://itunes.apple.com/lookup?bundleId=net.sunapps.invalid").
    with(headers: { 'Accept' => '*/*', 'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent' => 'Ruby' }).
    to_return(status: 200, body: File.read("fastlane_core/spec/responses/itunesLookup-net.sunapps.invalid.json"), headers: {})
end

# Executes the provided block after adjusting the ENV to have the
# provided keys and values set as defined in hash. After the block
# completes, restores the ENV to its previous state.
def with_env_values(hash)
  old_vals = ENV.select { |k, v| hash.include?(k) }
  hash.each do |k, v|
    ENV[k] = hash[k]
  end
  yield
ensure
  hash.each do |k, v|
    ENV.delete(k) unless old_vals.include?(k)
    ENV[k] = old_vals[k]
  end
end

def with_verbose(verbose)
  orig_verbose = FastlaneCore::Globals.verbose?
  FastlaneCore::Globals.verbose = verbose
  yield if block_given?
ensure
  FastlaneCore::Globals.verbose = orig_verbose
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
