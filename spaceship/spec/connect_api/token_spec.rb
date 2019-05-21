describe Spaceship::ConnectAPI::Token do
  let(:key_id) { 'BA5176BF04' }
  let(:issuer_id) { '693fbb20-54a0-4d94-88ce-8a6caf875439' }

  context 'init' do
    let(:private_key) do
      key = OpenSSL::PKey::EC.new('prime256v1')
      key.generate_key
      key
    end
    let(:public_key) do
      key = OpenSSL::PKey::EC.new(private_key)
      key.private_key = nil
      key
    end

    it 'generates proper token' do
      token = Spaceship::ConnectAPI::Token.new(key_id: key_id, issuer_id: issuer_id, key: private_key)
      expect(token.key_id).to eq(key_id)
      expect(token.issuer_id).to eq(issuer_id)

      payload, header = JWT.decode(token.text, public_key, true, { algorithm: 'ES256' })

      expect(payload['iss']).to eq(issuer_id)
      expect(payload['aud']).to eq('appstoreconnect-v1')
      expect(payload['exp']).to be > Time.now.to_i

      expect(header['kid']).to eq(key_id)
    end
  end
end
