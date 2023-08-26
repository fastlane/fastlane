require 'tempfile'

describe Spaceship::ConnectAPI::Token do
  let(:key_id) { 'BA5176BF04' }
  let(:issuer_id) { '693fbb20-54a0-4d94-88ce-8a6caf875439' }

  let(:fake_api_key_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key.json" }
  let(:fake_api_key_extra_fields_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key_extra_fields.json" }
  let(:fake_api_key_base64_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key_base64.json" }
  let(:fake_api_key_in_house_json_path) { "./spaceship/spec/connect_api/fixtures/asc_key_in_house.json" }

  let(:private_key) do
    json = JSON.parse(File.read(fake_api_key_json_path), { symbolize_names: true })
    json[:key]
  end

  context '#from_json_file' do
    it 'successfully creates token' do
      token = Spaceship::ConnectAPI::Token.from_json_file(fake_api_key_json_path)

      expect(token.key_id).to eq("D485S484")
      expect(token.issuer_id).to eq("061966a2-5f3c-4185-af13-70e66d2263f5")
      expect(token.in_house).to be_nil
    end

    it 'successfully creates token with extra fields' do
      token = Spaceship::ConnectAPI::Token.from_json_file(fake_api_key_extra_fields_json_path)

      expect(token.key_id).to eq("D485S484")
      expect(token.issuer_id).to eq("061966a2-5f3c-4185-af13-70e66d2263f5")
      expect(token.in_house).to be_nil
    end

    it 'successfully creates token with base64 encoded key' do
      json = JSON.parse(File.read(fake_api_key_json_path), { symbolize_names: true })

      expect(Base64).to receive(:decode64).and_call_original
      expect(OpenSSL::PKey::EC).to receive(:new).with(json[:key]).and_call_original

      token64 = Spaceship::ConnectAPI::Token.from_json_file(fake_api_key_base64_json_path)

      expect(token64.key_id).to eq("D485S484")
      expect(token64.issuer_id).to eq("061966a2-5f3c-4185-af13-70e66d2263f5")
      expect(token64.in_house).to be_nil
    end

    it 'successfully creates token with in_house' do
      token = Spaceship::ConnectAPI::Token.from_json_file(fake_api_key_in_house_json_path)

      expect(token.key_id).to eq("D485S484")
      expect(token.issuer_id).to eq("061966a2-5f3c-4185-af13-70e66d2263f5")
      expect(token.in_house).to eq(true)
    end

    it 'raises error with invalid JSON' do
      file = Tempfile.new('key.json')
      file.write('abc123')
      file.close

      expect do
        Spaceship::ConnectAPI::Token.from_json_file(file.path)
      end.to raise_error(JSON::ParserError, /unexpected token/)
    end

    it 'raises error with missing all keys' do
      file = Tempfile.new('key.json')
      file.write('{"thing":"thing"}')
      file.close
      expect do
        Spaceship::ConnectAPI::Token.from_json_file(file.path)
      end.to raise_error("App Store Connect API key JSON is missing field(s): key_id, issuer_id, key")
    end

    it 'raises error with missing key' do
      file = Tempfile.new('key.json')
      file.write('{"key_id":"thing", "issuer_id": "thing"}')
      file.close
      expect do
        Spaceship::ConnectAPI::Token.from_json_file(file.path)
      end.to raise_error("App Store Connect API key JSON is missing field(s): key")
    end
  end

  context '#from' do
    describe 'hash' do
      it 'with string keys' do
        token = Spaceship::ConnectAPI::Token.from(hash: {
          "key_id" => "key_id",
          "issuer_id" => "issuer_id",
          "key" => private_key,
          "duration" => 200,
          "in_house" => true
        })

        expect(token.key_id).to eq('key_id')
        expect(token.issuer_id).to eq('issuer_id')
        expect(token.text).not_to(be_nil)
        expect(token.duration).to eq(200)
        expect(token.in_house).to eq(true)
      end

      it 'with symbols keys' do
        token = Spaceship::ConnectAPI::Token.from(hash: {
          key_id: "key_id",
          issuer_id: "issuer_id",
          key: private_key,
          duration: 200,
          in_house: true
        })

        expect(token.key_id).to eq('key_id')
        expect(token.issuer_id).to eq('issuer_id')
        expect(token.text).not_to(be_nil)
        expect(token.duration).to eq(200)
        expect(token.in_house).to eq(true)
      end
    end
  end

  context '#create' do
    describe 'with arguments' do
      it "with key" do
        token = Spaceship::ConnectAPI::Token.create(
          key_id: "key_id",
          issuer_id: "issuer_id",
          key: private_key,
          duration: 200,
          in_house: true
        )

        expect(token.key_id).to eq('key_id')
        expect(token.issuer_id).to eq('issuer_id')
        expect(token.text).not_to(be_nil)
        expect(token.duration).to eq(200)
        expect(token.in_house).to eq(true)
      end

      it "with filepath" do
        expect(File).to receive(:binread).with('/path/to/file').and_return(private_key)
        token = Spaceship::ConnectAPI::Token.create(
          key_id: "key_id",
          issuer_id: "issuer_id",
          filepath: "/path/to/file",
          duration: 200,
          in_house: true
        )

        expect(token.key_id).to eq('key_id')
        expect(token.issuer_id).to eq('issuer_id')
        expect(token.text).not_to(be_nil)
        expect(token.duration).to eq(200)
        expect(token.in_house).to eq(true)
      end
    end

    describe 'with environment variables' do
      it "with key" do
        stub_const('ENV', {
          'SPACESHIP_CONNECT_API_KEY_ID' => 'key_id',
          'SPACESHIP_CONNECT_API_ISSUER_ID' => 'issuer_id',
          'SPACESHIP_CONNECT_API_KEY_FILEPATH' => nil,
          'SPACESHIP_CONNECT_API_TOKEN_DURATION' => '200',
          'SPACESHIP_CONNECT_API_IN_HOUSE' => 'no',
          'SPACESHIP_CONNECT_API_KEY' => private_key
        })

        token = Spaceship::ConnectAPI::Token.create

        expect(token.key_id).to eq('key_id')
        expect(token.issuer_id).to eq('issuer_id')
        expect(token.text).not_to(be_nil)
        expect(token.duration).to eq(200)
        expect(token.in_house).to eq(false)
      end

      it "with filepath" do
        expect(File).to receive(:binread).with('/path/to/file').and_return(private_key)
        stub_const('ENV', {
          'SPACESHIP_CONNECT_API_KEY_ID' => 'key_id',
          'SPACESHIP_CONNECT_API_ISSUER_ID' => 'issuer_id',
          'SPACESHIP_CONNECT_API_KEY_FILEPATH' => '/path/to/file',
          'SPACESHIP_CONNECT_API_TOKEN_DURATION' => '200',
          'SPACESHIP_CONNECT_API_IN_HOUSE' => 'true',
          'SPACESHIP_CONNECT_API_KEY' => nil
        })

        token = Spaceship::ConnectAPI::Token.create

        expect(token.key_id).to eq('key_id')
        expect(token.issuer_id).to eq('issuer_id')
        expect(token.text).not_to(be_nil)
        expect(token.duration).to eq(200)
        expect(token.in_house).to eq(true)
      end
    end
  end

  context 'init' do
    it 'generates proper token' do
      key = OpenSSL::PKey::EC.generate('prime256v1')
      token = Spaceship::ConnectAPI::Token.new(key_id: key_id, issuer_id: issuer_id, key: key)
      expect(token.key_id).to eq(key_id)
      expect(token.issuer_id).to eq(issuer_id)

      payload, header = JWT.decode(token.text, key, true, { algorithm: 'ES256' })

      expect(payload['iss']).to eq(issuer_id)
      expect(payload['iat']).to eq(Time.now.to_i)
      expect(payload['aud']).to eq('appstoreconnect-v1')
      expect(payload['exp']).to be > Time.now.to_i

      expect(header['kid']).to eq(key_id)
      expect(header['typ']).to eq('JWT')
    end
  end
end
