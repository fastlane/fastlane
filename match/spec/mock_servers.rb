RSpec.configure do |config|
  config.include(WebMock::API)

  config.before do
    stub_request(:put, %r(http://169.254.169.254/latest/.*)).
      with(
        headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'aws-sdk-ruby3/3.167.0',
        'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
        }
    ).
      to_return(status: 200, body: "", headers: {})
    stub_request(:get, %r(http://169.254.169.254/latest/.*)).
      with(
        headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'aws-sdk-ruby3/3.167.0',
        'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
        }
    ).
      to_return(status: 200, body: "", headers: {})
    stub_request(:post, %r(http://169.254.169.254/latest/.*)).
      with(
        headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'aws-sdk-ruby3/3.167.0',
        'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
        }
    ).
      to_return(status: 200, body: "", headers: {})
  end
end
