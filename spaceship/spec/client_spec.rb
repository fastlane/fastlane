describe Spaceship::Client do
  class TestClient < Spaceship::Client
    def self.hostname
      "http://example.com"
    end

    def req_home
      request(:get, TestClient.hostname)
    end

    def send_login_request(_user, _password)
      true
    end
  end

  class TestResponse
    attr_accessor :body
    attr_accessor :status

    def initialize(body = nil, status = 200)
      @body = body
      @status = status
    end
  end

  let(:subject) { TestClient.new }
  let(:unauth_error) { Spaceship::Client::UnauthorizedAccessError.new }
  let(:test_uri) { "http://example.com" }

  let(:default_body) { '{foo: "bar"}' }

  def stub_client_request(error, times, status, body)
    stub_request(:get, test_uri).
      to_raise(error).times(times).then.
      to_return(status: status, body: body)
  end

  def stub_client_retry_auth(status_error, times, status_ok, body)
    stub_request(:get, test_uri).
      to_return(status: status_error, body: body).times(times).
      then.to_return(status: status_ok, body: body)
  end

  describe 'detect_most_common_errors_and_raise_exceptions' do
    # this test is strange, the `error` has a typo "InsufficentPermissions" and is not really relevant
    it "raises Spaceship::InsufficientPermissions for InsufficentPermissions" do
      body = JSON.generate({ messages: { error: "InsufficentPermissions" } })
      stub_client_request(Spaceship::InsufficientPermissions, 6, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::InsufficientPermissions)
    end

    it "raises Spaceship::InsufficientPermissions for Forbidden" do
      body = JSON.generate({ messages: { error: "Forbidden" } })
      stub_client_request(Spaceship::InsufficientPermissions, 6, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::InsufficientPermissions)
    end

    it "raises Spaceship::InsufficientPermissions for insufficient privileges" do
      body = JSON.generate({ messages: { error: "insufficient privileges" } })
      stub_client_request(Spaceship::InsufficientPermissions, 6, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::InsufficientPermissions)
    end

    it "raises Spaceship::InternalServerError" do
      stub_client_request(Spaceship::GatewayTimeoutError, 6, 504, "<html>Internal Server - Read</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::GatewayTimeoutError)
    end

    it "raises Spaceship::GatewayTimeoutError" do
      stub_client_request(Spaceship::GatewayTimeoutError, 6, 504, "<html>Gateway Timeout - In Read</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::GatewayTimeoutError)
    end

    it "raises Spaceship::ProgramLicenseAgreementUpdated" do
      stub_client_request(Spaceship::ProgramLicenseAgreementUpdated, 6, 200, "Program License Agreement")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::ProgramLicenseAgreementUpdated)
    end

    it "raises Spaceship::AccessForbiddenError" do
      stub_client_request(Spaceship::AccessForbiddenError, 6, 403, "<html>Access Denied - In Read</html>")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::AccessForbiddenError)
    end

    it "raises Spaceship::ProgramLicenseAgreementUpdated" do
      stub_client_request(Spaceship::ProgramLicenseAgreementUpdated, 6, 200, "Program License Agreement")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::ProgramLicenseAgreementUpdated)
    end

    it "raises Spaceship::TooManyRequestsError" do
      stub_client_request(Spaceship::TooManyRequestsError.new({}), 6, 429, "Program License Agreement")

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::TooManyRequestsError)
    end
  end

  describe 'retry' do
    [
      Faraday::TimeoutError,
      Faraday::ConnectionFailed,
      Faraday::ParsingError,
      Spaceship::BadGatewayError,
      Spaceship::InternalServerError,
      Spaceship::GatewayTimeoutError,
      Spaceship::AccessForbiddenError
    ].each do |thrown|
      it "re-raises when retry limit reached throwing #{thrown}" do
        stub_client_request(thrown, 6, 200, nil)

        expect do
          subject.req_home
        end.to raise_error(thrown)
      end

      it "retries when #{thrown} error raised" do
        stub_client_request(thrown, 2, 200, default_body)

        expect(subject.req_home.body).to eq(default_body)
      end
    end

    it "raises AppleTimeoutError when response contains '302 Found'" do
      ClientStubbing.stub_connection_timeout_302

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::AppleTimeoutError)
    end

    it "raises BadGatewayError when response contains 'Bad Gateway'" do
      body = <<BODY
      <!DOCTYPE html>
<html lang="en">
<head>
    <style>
        body {
            font-family: "Helvetica Neue", "HelveticaNeue", Helvetica, Arial, sans-serif;
            font-size: 15px;
            font-weight: 200;
            line-height: 20px;
            color: #4c4c4c;
            text-align: center;
        }

        .section {
            margin-top: 50px;
        }
    </style>
</head>
<body>
<div class="section">
    <h1>&#63743;</h1>

    <h3>Bad Gateway</h3>
    <p>Correlation Key: XXXXXXXXXXXXXXXXXXXX</p>
</div>
</body>
</html>
BODY
      stub_client_retry_auth(502, 1, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::BadGatewayError)
    end
  end

  describe 'retry' do
    [
      Faraday::TimeoutError,
      Faraday::ConnectionFailed,
      Faraday::ParsingError,
      Spaceship::BadGatewayError,
      Spaceship::InternalServerError,
      Spaceship::GatewayTimeoutError,
      Spaceship::AccessForbiddenError
    ].each do |thrown|
      it "re-raises when retry limit reached throwing #{thrown}" do
        stub_client_request(thrown, 6, 200, nil)

        expect do
          subject.req_home
        end.to raise_error(thrown)
      end

      it "retries when #{thrown} error raised" do
        stub_client_request(thrown, 2, 200, default_body)

        expect(subject.req_home.body).to eq(default_body)
      end
    end

    it "raises AppleTimeoutError when response contains '302 Found'" do
      ClientStubbing.stub_connection_timeout_302

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::AppleTimeoutError)
    end

    it "raises BadGatewayError when response contains 'Bad Gateway'" do
      body = <<BODY
      <!DOCTYPE html>
<html lang="en">
<head>
    <style>
        body {
            font-family: "Helvetica Neue", "HelveticaNeue", Helvetica, Arial, sans-serif;
            font-size: 15px;
            font-weight: 200;
            line-height: 20px;
            color: #4c4c4c;
            text-align: center;
        }

        .section {
            margin-top: 50px;
        }
    </style>
</head>
<body>
<div class="section">
    <h1>&#63743;</h1>

    <h3>Bad Gateway</h3>
    <p>Correlation Key: XXXXXXXXXXXXXXXXXXXX</p>
</div>
</body>
</html>
BODY
      stub_client_retry_auth(502, 1, 200, body)

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::BadGatewayError)
    end

    it "successfully retries request after logging in again when UnauthorizedAccess Error raised" do
      subject.login
      stub_client_retry_auth(401, 1, 200, default_body)

      expect(subject.req_home.body).to eq(default_body)
    end

    it "fails to retry request if login fails in retry block when UnauthorizedAccess Error raised" do
      subject.login
      stub_client_retry_auth(401, 1, 200, default_body)

      # the next login will fail
      def subject.send_login_request(_user, _password)
        raise Spaceship::Client::UnauthorizedAccessError.new, "Faked"
      end

      expect do
        subject.req_home
      end.to raise_error(Spaceship::Client::UnauthorizedAccessError)
    end

    describe "retry when user and password not fetched from CredentialManager" do
      let(:the_user) { 'u' }
      let(:the_password) { 'p' }

      it "is able to retry and login successfully" do
        def subject.send_login_request(user, password)
          can_login = (user == 'u' && password == 'p')
          raise Spaceship::Client::UnauthorizedAccessError.new, "Faked" unless can_login
          true
        end

        subject.login(the_user, the_password)

        stub_client_retry_auth(401, 1, 200, default_body)

        expect(subject.req_home.body).to eq(default_body)
      end
    end
  end

  describe "#log_response" do
    it 'handles ASCII-8BIT to UTF-8 encoding gracefully' do
      response = TestResponse.new([130, 5, 3120, 130, 4, 171, 160, 3, 2].pack('C*'))
      expect(subject.send(:log_response, :get, TestClient.hostname, response)).to be_truthy
    end
  end

  describe "#persistent_cookie_path" do
    before do
      subject.login("username", "password")
    end

    after do
      ENV.delete("SPACESHIP_COOKIE_PATH")
    end

    it "uses $SPACESHIP_COOKIE_PATH when set" do
      tmp_path = Dir.mktmpdir
      ENV["SPACESHIP_COOKIE_PATH"] = "#{tmp_path}/custom_path"
      expect(subject.persistent_cookie_path).to eq("#{tmp_path}/custom_path/spaceship/username/cookie")
    end

    it "uses home dir by default" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(true)
      expect(subject.persistent_cookie_path).to eq(File.expand_path("~/.fastlane/spaceship/username/cookie"))
    end

    it "supports legacy .spaceship path" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~")).and_return(true)
      expect(subject.persistent_cookie_path).to eq(File.expand_path("~/.spaceship/username/cookie"))
    end

    it "uses /var/tmp if home not available" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("/var/tmp")).and_return(true)
      expect(subject.persistent_cookie_path).to eq(File.expand_path("/var/tmp/spaceship/username/cookie"))
    end

    it "falls back to Dir.tmpdir as last resort" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("/var/tmp")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(Dir.tmpdir).and_return(true)
      expect(subject.persistent_cookie_path).to eq("#{Dir.tmpdir}/spaceship/username/cookie")
    end
  end
end
