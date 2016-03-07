require 'spec_helper'

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
    { "Timeout" => Faraday::Error::TimeoutError.new,
      "Connection failed" => Faraday::Error::ConnectionFailed.new("Connection Failed"),
      "EPIPE" => Errno::EPIPE }.each do |name, exception|
      it "re-raises #{exception} error when retry limit reached" do
        stub_client_request(exception, 6, 200, nil)

        expect do
          subject.req_home
        end.to raise_error(exception)
      end

      it "retries when #{exception} error raised" do
        stub_client_request(exception, 2, 200, default_body)

        expect(subject.req_home.body).to eq(default_body)
      end
    end

    it "raises AppleTimeoutError when response contains '302 Found'" do
      stub_connection_timeout_302

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
end
