RSpec::Matchers.define(:a_configuration_matching) do |expected|
  match do |actual|
    actual.values == expected.values
  end
end

def before_each_match
  ENV["DELIVER_USER"] = "flapple@krausefx.com"
  ENV["DELIVER_PASSWORD"] = "so_secret"
end

def stub_request(*args)
  WebMock::API.stub_request(*args)
end

stub_request(:put, "http://169.254.169.254/latest/api/token").
  with(
    headers: {
    'Accept' => '*/*',
    'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'User-Agent' => 'aws-sdk-ruby3/3.167.0',
    'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
    }
).
  to_return(status: 200, body: "", headers: {})
