describe Match do
  describe Match::Encryption::MatchDataEncryption do
    let(:v1) { Match::Encryption::EncryptionV1.new }
    let(:v2) { Match::Encryption::EncryptionV2.new }
    let(:e) { Match::Encryption::MatchDataEncryption.new }
    let(:salt) { salt = SecureRandom.random_bytes(8) }

    let(:data) { "Hello World" }
    let(:password) { '2"QAHg@v(Qp{=*n^' }

    it "decrypts V1 Encryption with default hash" do
      encryption = v1.encrypt(data: data, password: password, salt: salt)
      encrypted_data = Match::Encryption::MatchDataEncryption::V1_PREFIX + salt + encryption[:encrypted_data]
      encoded_encrypted_data = Base64.encode64(encrypted_data)

      expect(e.decrypt(base64encoded_encrypted: encoded_encrypted_data, password: password)).to eq(data)
    end

    it "decrypts V1 Encryption with SHA256 hash when the decryption fails when given the default hash" do
      encryption = v1.encrypt(data: data, password: password, salt: salt, hash_algorithm: "SHA256")
      encrypted_data = Match::Encryption::MatchDataEncryption::V1_PREFIX + salt + encryption[:encrypted_data]
      encoded_encrypted_data = Base64.encode64(encrypted_data)

      eMock = double("EncryptionV1")
      # make it fail with the default hash
      allow(eMock).to receive(:decrypt).with(encrypted_data: encryption[:encrypted_data], password: password, salt: salt).and_raise(OpenSSL::Cipher::CipherError)
      allow(eMock).to receive(:decrypt).with(encrypted_data: encryption[:encrypted_data], password: password, salt: salt, hash_algorithm: "SHA256").and_return(data)

      allow(Match::Encryption::EncryptionV1).to receive(:new).and_return(eMock)
      expect(e.decrypt(base64encoded_encrypted: encoded_encrypted_data, password: password)).to eq(data)
    end

    it "fails to decrypt V1 Encryption with SHA256 hash when the decryption doesn't fail when given the default hash" do
      encryption = v1.encrypt(data: data, password: password, salt: salt, hash_algorithm: "SHA256")
      encrypted_data = Match::Encryption::MatchDataEncryption::V1_PREFIX + salt + encryption[:encrypted_data]
      encoded_encrypted_data = Base64.encode64(encrypted_data)

      eMock = double("EncryptionV1")
      # make it return garbage
      garbage = "garbage"
      allow(eMock).to receive(:decrypt).with(encrypted_data: encryption[:encrypted_data], password: password, salt: salt).and_return(garbage)

      allow(Match::Encryption::EncryptionV1).to receive(:new).and_return(eMock)
      expect(e.decrypt(base64encoded_encrypted: encoded_encrypted_data, password: password)).to eq(garbage)
    end
  end
end
