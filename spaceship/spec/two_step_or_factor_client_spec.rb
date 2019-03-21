require_relative 'mock_servers'

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

    def self.user
      "foouser"
    end

    def ask_for_2fa_code(text)
      '123'
    end

    def persistent_cookie_path
      'foo' # TODO creates file in current directory with useless content
    end
  end

  let(:subject) { TestClient.new }

  let(:phone_numbers_json_string) do
    '
      [
        { "id" : 1, "numberWithDialCode" : "+49 •••• •••••85", "obfuscatedNumber" : "•••• •••••85", "pushMode" : "sms" },
        { "id" : 2, "numberWithDialCode" : "+49 ••••• •••••81", "obfuscatedNumber" : "••••• •••••81", "pushMode" : "sms" },
        { "id" : 3, "numberWithDialCode" : "+1 (•••) •••-••66", "obfuscatedNumber" : "(•••) •••-••66", "pushMode" : "sms" },
        { "id" : 4, "numberWithDialCode" : "+39 ••• ••• ••71", "obfuscatedNumber" : "••• ••• ••71", "pushMode" : "sms" },
        { "id" : 5, "numberWithDialCode" : "+353 •• ••• ••43", "obfuscatedNumber" : "••• ••• •43", "pushMode" : "sms" }
      ]
    '
  end
  let(:phone_numbers) { JSON.parse(phone_numbers_json_string) }

  describe 'phone_id_from_number' do
    {
      "+49 123 4567885" => 1,
      "+4912341234581" => 2,
      "+1-123-456-7866" => 3,
      "+39 123 456 7871" => 4,
      "+353123456743" => 5
    }.each do |number_to_test, expected_phone_id|
      it "selects correct phone id #{expected_phone_id} for provided phone number #{number_to_test}" do
        phone_id = subject.phone_id_from_number(phone_numbers, number_to_test)
        expect(phone_id).to eq(expected_phone_id)
      end
    end

    it "raises an error with unknown phone number" do
      phone_number = 'la le lu'
      expect do
        phone_id = subject.phone_id_from_number(phone_numbers, phone_number)
      end.to raise_error(Spaceship::Tunes::Error)
    end
  end

  describe 'handle_two_factor' do
    let(:response_fixture) { File.read(File.join('spaceship', 'spec', 'fixtures', 'client_appleauth_auth_2fa_response.json'), encoding: 'utf-8') }

    it 'successfully requests a session with SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER set to a known phone number and the correct security code being entered' do
      # call 1
      MockAPI::DeveloperPortalServer.put('https://idmsa.apple.com/appleauth/auth/verify/phone') do
        {}
      end

      # call 2
      MockAPI::DeveloperPortalServer.post('https://idmsa.apple.com/appleauth/auth/verify/phone/securitycode') do
        {}
      end

      # call 3
      MockAPI::DeveloperPortalServer.get('https://idmsa.apple.com/appleauth/auth/2sv/trust') do
        {}
      end

      ENV['SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER'] = '+491622850885'

      response = OpenStruct.new
      response.body = JSON.parse(response_fixture)
      bool = subject.handle_two_factor(response)

      ENV.delete('SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER')

      expect(bool).to eq(true)

      # call 1
      expect(WebMock).to have_requested(:put, 'https://idmsa.apple.com/appleauth/auth/verify/phone')
        .with(body: { phoneNumber: { id: 1 }, mode: "sms" })

      # call 2
      expect(WebMock).to have_requested(:post, 'https://idmsa.apple.com/appleauth/auth/verify/phone/securitycode')
        .with(body: { securityCode: { code: "123" }, phoneNumber: { id: 1 }, mode: "sms" })

      # call 3
      expect(WebMock).to have_requested(:get, 'https://idmsa.apple.com/appleauth/auth/2sv/trust')
    end
  end
end
