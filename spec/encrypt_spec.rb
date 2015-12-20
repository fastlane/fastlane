describe Match do
  describe Match::Encrypt do
    before do
      @directory = Dir.mktmpdir
      @content = "#{Time.now.to_i} so random"
      @full_path = File.join(@directory, "randomFile.mobileprovision")
      File.write(@full_path, @content)
      @git_url = "https://github.com/fastlane/so_random"
      allow(Dir).to receive(:mktmpdir).and_return(@directory)
      ENV["MATCH_PASSWORD"] = "my_pass"

      @e = Match::Encrypt.new
    end

    it "encrypt" do
      @e = Match::Encrypt.new
      @e.encrypt_repo(path: @directory, git_url: @git_url)
      expect(File.read(@full_path)).to_not eq(@content)

      @e.decrypt_repo(path: @directory, git_url: @git_url)
      expect(File.read(@full_path)).to eq(@content)
    end

    it "raises an exception if invalid password is passed" do
      @e.encrypt_repo(path: @directory, git_url: @git_url)
      expect(File.read(@full_path)).to_not eq(@content)

      ENV["MATCH_PASSWORD"] = "invalid"
      expect do
        @e.decrypt_repo(path: @directory, git_url: @git_url)
      end.to raise_error
    end

    it "raises an exception if no password is supplied" do
      ENV["MATCH_PASSWORD"] = ""
      expect do
        @e.encrypt_repo(path: @directory, git_url: @git_url)
      end.to raise_error
    end
  end
end
