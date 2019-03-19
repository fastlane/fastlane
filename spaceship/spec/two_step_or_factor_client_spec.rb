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
  let(:phone_numbers_json_string) do
    '
      [
        { "id" : 1, "numberWithDialCode" : "+49 •••• •••••85", "obfuscatedNumber" : "•••• •••••85", "pushMode" : "sms" },
        { "id" : 2, "numberWithDialCode" : "+49 ••••• •••••81", "obfuscatedNumber" : "••••• •••••81", "pushMode" : "sms" },
        { "id" : 3, "numberWithDialCode" : "+1 (•••) •••-••66", "obfuscatedNumber" : "(•••) •••-••66", "pushMode" : "sms" },
        { "id" : 4, "numberWithDialCode" : "+39 ••• ••• ••71", "obfuscatedNumber" : "••• ••• ••71", "pushMode" : "sms" }
      ]
    '
  end
  let(:phone_numbers) { JSON.parse(phone_numbers_json_string) }

  describe 'phone_id_from_number' do
    {
      "+49 123 4567885" => 1,
      "+4912341234581" => 2,
      "+1-123-456-7866" => 3,
      "+39 123 456 7871" => 4
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
end
