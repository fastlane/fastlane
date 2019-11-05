require_relative 'mock_servers'

describe Spaceship::Client do
  class TwoStepOrFactorClient < Spaceship::Client
    def self.hostname
      "http://example.com"
    end

    def ask_for_2fa_code(text)
      '123'
    end

    def store_cookie(path: nil)
      true
    end

    # these tests actually "send requests" - and `update_request_headers` would otherwise
    # add data to the headers that does not exist / is empty which will crash faraday later
    def update_request_headers(req)
      req
    end
  end

  let(:subject) { TwoStepOrFactorClient.new }

  let(:phone_numbers_json_string) do
    '
      [
        { "id" : 1, "numberWithDialCode" : "+49 •••• •••••85", "obfuscatedNumber" : "•••• •••••85", "pushMode" : "sms" },
        { "id" : 2, "numberWithDialCode" : "+49 ••••• •••••81", "obfuscatedNumber" : "••••• •••••81", "pushMode" : "sms" },
        { "id" : 3, "numberWithDialCode" : "+1 (•••) •••-••66", "obfuscatedNumber" : "(•••) •••-••66", "pushMode" : "sms" },
        { "id" : 4, "numberWithDialCode" : "+39 ••• ••• ••71", "obfuscatedNumber" : "••• ••• ••71", "pushMode" : "sms" },
        { "id" : 5, "numberWithDialCode" : "+353 •• ••• ••43", "obfuscatedNumber" : "••• ••• •43", "pushMode" : "sms" },
        { "id" : 6, "numberWithDialCode" : "+375 • ••• •••-••-59", "obfuscatedNumber" : "• ••• •••-••-59", "pushMode" : "sms" }
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
      "+353123456743" => 5,
      "+375 00 000-00-59" => 6
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
    let(:response) { OpenStruct.new }
    before do
      response.body = JSON.parse(response_fixture)
    end

    describe 'with SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER set' do
      after do
        ENV.delete('SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER')
      end

      it 'to a known phone number returns true (and sends the correct requests)' do
        phone_number = '+49 123 4567885'
        ENV['SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER'] = phone_number

        response = OpenStruct.new
        response.body = JSON.parse(response_fixture)
        bool = subject.handle_two_factor(response)

        expect(bool).to eq(true)

        # expected requests
        expect(WebMock).to have_requested(:put, 'https://idmsa.apple.com/appleauth/auth/verify/phone').with(body: { phoneNumber: { id: 1 }, mode: "sms" })
        expect(WebMock).to have_requested(:post, 'https://idmsa.apple.com/appleauth/auth/verify/phone/securitycode').with(body: { securityCode: { code: "123" }, phoneNumber: { id: 1 }, mode: "sms" })
        expect(WebMock).to have_requested(:get, 'https://idmsa.apple.com/appleauth/auth/2sv/trust')
      end

      it 'to a unknown phone number throws an exception' do
        phone_number = '+49 123 4567800'
        ENV['SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER'] = phone_number

        expect do
          bool = subject.handle_two_factor(response)
        end.to raise_error(Spaceship::Tunes::Error)
      end
    end

    describe 'with SPACESHIP_2FA_SMS_DEFAULT_PHONE_NUMBER not set' do
      # 1. input of pushed code
      # 2. input of `sms`, then selection of phone, then input of sms-ed code
    end
  end
end
