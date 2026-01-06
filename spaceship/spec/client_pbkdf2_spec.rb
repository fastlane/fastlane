describe Spaceship::Client do
  class TestClient < Spaceship::Client
    def self.hostname
      "http://example.com"
    end
  end

  let(:subject) { TestClient.new }

  describe '#pbkdf2' do
    let(:password) { 'password123' }
    let(:salt) { 'salt'.b }
    let(:iterations) { 1000 }
    let(:key_length) { 32 }

    it 'calculates pbkdf2 for s2k protocol' do
      result = subject.pbkdf2(password, salt, iterations, key_length, 's2k')
      expect(result).to_not(be_nil)
      expect(result.length).to(eq(key_length))

      # Manual calculation for verification
      hashed_password = OpenSSL::Digest::SHA256.digest(password)
      expected = OpenSSL::PKCS5.pbkdf2_hmac(hashed_password, salt, iterations, key_length, OpenSSL::Digest::SHA256.new)
      expect(result).to(eq(expected))
    end

    it 'calculates pbkdf2 for s2k_fo protocol' do
      expect(Spaceship::Globals).to(receive(:verbose?).and_return(true))
      expect(subject).to(receive(:puts).with("Using legacy s2k_fo protocol for password digest"))

      result = subject.pbkdf2(password, salt, iterations, key_length, 's2k_fo')
      expect(result).to_not(be_nil)
      expect(result.length).to(eq(key_length))

      # Manual calculation for verification
      hashed_password = OpenSSL::Digest::SHA256.digest(password)
      # s2k_fo does: password = to_byte(to_hex(password))
      fo_password = [hashed_password.unpack1('H*')].pack('H*')
      expected = OpenSSL::PKCS5.pbkdf2_hmac(fo_password, salt, iterations, key_length, OpenSSL::Digest::SHA256.new)
      expect(result).to(eq(expected))
    end

    it 'calculates the same result for s2k and s2k_fo in the current environment' do
      res_s2k = subject.pbkdf2(password, salt, iterations, key_length, 's2k')
      res_s2k_fo = subject.pbkdf2(password, salt, iterations, key_length, 's2k_fo')
      expect(res_s2k).to(eq(res_s2k_fo))
    end
  end

  describe '#to_hex and #to_byte' do
    it 'converts string to hex and back' do
      str = "hello world"
      hex = subject.to_hex(str)
      expect(hex).to(eq("68656c6c6f20776f726c64"))
      expect(subject.to_byte(hex)).to(eq(str))
    end

    it 'handles binary data' do
      binary = "\x00\xFF\x00\xFF".b
      hex = subject.to_hex(binary)
      expect(hex).to(eq("00ff00ff"))
      expect(subject.to_byte(hex)).to(eq(binary))
    end
  end
end
