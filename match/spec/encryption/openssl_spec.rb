describe Match do
  describe Match::Encryption::OpenSSL do
    before do
      @directory = Dir.mktmpdir
      @content = "#{Time.now.to_i} so random"
      @full_path = File.join(@directory, "randomFile.mobileprovision")
      File.write(@full_path, @content)
      @git_url = "https://github.com/fastlane/fastlane/tree/master/so_random"
      allow(Dir).to receive(:mktmpdir).and_return(@directory)
      ENV["MATCH_PASSWORD"] = '2"QAHg@v(Qp{=*n^'

      @e = Match::Encryption::OpenSSL.new(
        keychain_name: @git_url,
        working_directory: @directory
      )
    end

    it "encrypt" do
      @e.encrypt_files
      expect(File.read(@full_path)).to_not(eq(@content))

      @e.decrypt_files
      expect(File.read(@full_path)).to eq(@content)
    end

    it "raises an exception if invalid password is passed" do
      @e.encrypt_files
      expect(File.read(@full_path)).to_not(eq(@content))

      ENV["MATCH_PASSWORD"] = "invalid"
      expect do
        @e.decrypt_files
      end.to raise_error("Invalid password passed via 'MATCH_PASSWORD'")
    end

    it "raises an exception if no password is supplied" do
      ENV["MATCH_PASSWORD"] = ""
      expect do
        @e.encrypt_files
      end.to raise_error("No password supplied")
    end
  end
end
