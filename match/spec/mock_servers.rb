RSpec.configure do |config|
  config.include(WebMock::API)

  config.before do
    stub_request(:put, %r(http://169.254.169.254/latest/.*)).
      to_return(status: 200, body: "", headers: {})
    stub_request(:get, %r(http://169.254.169.254/latest/.*)).
      to_return(status: 200, body: "", headers: {})
    stub_request(:post, %r(http://169.254.169.254/latest/.*)).
      to_return(status: 200, body: "", headers: {})
  end
end
