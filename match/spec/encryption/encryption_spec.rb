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

  describe Match::Encryption::MatchFileEncryption do
    around do |example|
      old_umask = File.umask(0o022)
      begin
        example.run
      ensure
        File.umask(old_umask)
      end
    end

    def decrypted_mode(filename)
      Dir.mktmpdir do |dir|
        path = File.join(dir, filename)
        File.write(path, "content")
        e = Match::Encryption::MatchFileEncryption.new
        e.encrypt(file_path: path, password: "password")
        expect(File.stat(path).mode & 0o777).to eq(0o644) unless FastlaneCore::Helper.windows?
        e.decrypt(file_path: path, password: "password")
        expect(File.read(path)).to eq("content")
        File.stat(path).mode & 0o777
      end
    end

    it "makes a decrypted private key readable only by its owner" do
      expect(decrypted_mode("key.p12")).to eq(0o600) unless FastlaneCore::Helper.windows?
    end

    it "keeps the mode of a decrypted certificate" do
      expect(decrypted_mode("cert.cer")).to eq(0o644) unless FastlaneCore::Helper.windows?
    end
  end
end
