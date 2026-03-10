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
      result = subject.pbkdf2(password, salt, iterations, key_length, 's2k_fo')

      hashed_password = OpenSSL::Digest::SHA256.digest(password)
      fo_password = hashed_password.unpack1('H*') # <-- hex STRING, not packed back
      expected = OpenSSL::PKCS5.pbkdf2_hmac(fo_password, salt, iterations, key_length, OpenSSL::Digest::SHA256.new)

      expect(result).to eq(expected)
    end

    it 'produces different results for s2k vs s2k_fo' do
      res_s2k = subject.pbkdf2(password, salt, iterations, key_length, 's2k')
      res_s2k_fo = subject.pbkdf2(password, salt, iterations, key_length, 's2k_fo')
      expect(res_s2k).not_to eq(res_s2k_fo)
    end

    it 'raises SIRPAuthenticationError for unsupported protocol' do
      expect do
        subject.pbkdf2(password, salt, iterations, key_length, 'unsupported')
      end.to raise_error(Spaceship::SIRPAuthenticationError, "Unsupported protocol 'unsupported' for pbkdf2")
    end
  end

  describe '#to_hex' do
    it 'converts string to hex' do
      str = "hello world"
      hex = subject.to_hex(str)
      expect(hex).to(eq("68656c6c6f20776f726c64"))
    end
    it 'converts binary data to hex' do
      binary = "\x00\xFF\x00\xFF".b
      hex = subject.to_hex(binary)
      expect(hex).to(eq("00ff00ff"))
    end
  end
  describe '#to_byte' do
    it 'converts hex back to string' do
      hex = "68656c6c6f20776f726c64"
      expect(subject.to_byte(hex)).to(eq("hello world"))
    end
    it 'converts hex back to binary data' do
      hex = "00ff00ff"
      expect(subject.to_byte(hex)).to(eq("\x00\xFF\x00\xFF".b))
    end
  end
end
