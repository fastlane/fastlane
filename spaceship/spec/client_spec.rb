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

    def initialize(body = nil)
      @body = body
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

  describe 'retry' do
    [
      Faraday::Error::TimeoutError,
      Faraday::Error::ConnectionFailed,
      Faraday::ParsingError
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

    it "successfully retries request after logging in again when UnauthorizedAccess Error raised" do
      subject.login
      stub_client_retry_auth(401, 1, 200, default_body)

      expect(subject.req_home.body).to eq(default_body)
    end

    it "fails to retry request if loggin fails in retry block when UnauthorizedAccess Error raised" do
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
      ENV["SPACESHIP_COOKIE_PATH"] = "/custom_path"
      expect(subject.persistent_cookie_path).to eq("/custom_path/spaceship/username/cookie")
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
      allow(subject).to receive(:directory_accessible?).with("/var/tmp").and_return(true)
      expect(subject.persistent_cookie_path).to eq("/var/tmp/spaceship/username/cookie")
    end

    it "falls back to Dir.tmpdir as last resort" do
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with(File.expand_path("~/.fastlane")).and_return(false)
      allow(subject).to receive(:directory_accessible?).with("/var/tmp").and_return(false)
      allow(subject).to receive(:directory_accessible?).with(Dir.tmpdir).and_return(true)
      expect(subject.persistent_cookie_path).to eq("#{Dir.tmpdir}/spaceship/username/cookie")
    end
  end
end
