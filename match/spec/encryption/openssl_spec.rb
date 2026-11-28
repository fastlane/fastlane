describe Match do
  describe Match::Encryption::OpenSSL do
    before do
      @directory = Dir.mktmpdir
      profile_path = "./match/spec/fixtures/test.mobileprovision"
      FileUtils.cp(profile_path, @directory)
      @full_path = File.join(@directory, "test.mobileprovision")
      @content = File.binread(@full_path)
      @git_url = "https://github.com/fastlane/fastlane/tree/master/so_random"
      allow(Dir).to receive(:mktmpdir).and_return(@directory)
      stub_const('ENV', { "MATCH_PASSWORD" => '2"QAHg@v(Qp{=*n^' })

      @e = Match::Encryption::OpenSSL.new(
        keychain_name: @git_url,
        working_directory: @directory
      )
    end

    it "first encrypt, different content, then decrypt, initial content again" do
      @e.encrypt_files
      expect(File.binread(@full_path)).to_not(eq(@content))

      @e.decrypt_files
      expect(File.binread(@full_path)).to eq(@content)
    end

    it "raises an exception if invalid password is passed" do
      stub_const('ENV', { "MATCH_PASSWORD" => '2"QAHg@v(Qp{=*n^' })
      @e.encrypt_files
      expect(File.read(@full_path)).to_not(eq(@content))

      stub_const('ENV', { "MATCH_PASSWORD" => "invalid" })
      expect do
        @e.decrypt_files
      end.to raise_error("Invalid password passed via 'MATCH_PASSWORD'")
    end

    it "raises an exception if no password is supplied" do
      stub_const('ENV', { "MATCH_PASSWORD" => "" })
      expect do
        @e.encrypt_files
      end.to raise_error("No password supplied")
    end

    it "doesn't raise an exception if no env var is supplied but custom password is" do
      stub_const('ENV', { "MATCH_PASSWORD" => "" })
      expect do
        @e.encrypt_files(password: "some custom password")
      end.to_not(raise_error)
    end

    it "given a custom password argument, then it should be given precedence when encrypting file, even when MATCH_PASSWORD is set" do
      stub_const('ENV', { "MATCH_PASSWORD" => "something else" })
      new_password = '2"QAHg@v(Qp{=*n^'
      @e.encrypt_files(password: new_password)
      expect(File.binread(@full_path)).to_not(eq(@content))

      stub_const('ENV', { "MATCH_PASSWORD" => new_password })
      @e.decrypt_files
      expect(File.binread(@full_path)).to eq(@content)
    end

    describe "behavior of force_legacy_encryption parameter" do

      before do
        @match_encryption_double = instance_double(Match::Encryption::MatchFileEncryption)

        expect(Match::Encryption::MatchFileEncryption)
          .to(receive(:new))
          .and_return(@match_encryption_double)
      end

      it "defaults to false and uses v2 encryption" do
        expect(@match_encryption_double)
          .to(receive(:encrypt))
          .with(file_path: anything, password: anything, version: 2)

        @e.encrypt_files
      end

      it "uses v1 when force_legacy_encryption is true" do
        enc = Match::Encryption::OpenSSL.new(
          keychain_name: @git_url,
          working_directory: @directory,
          force_legacy_encryption: true
        )

        expect(@match_encryption_double)
          .to(receive(:encrypt))
          .with(file_path: anything, password: anything, version: 1)

        enc.encrypt_files
      end

      it "uses v2 when force_legacy_encryption is false" do
        enc = Match::Encryption::OpenSSL.new(
          keychain_name: @git_url,
          working_directory: @directory,
          force_legacy_encryption: false
        )

        expect(@match_encryption_double)
          .to(receive(:encrypt))
          .with(file_path: anything, password: anything, version: 2)

        enc.encrypt_files
      end
    end

    describe "storing the passphrase in the keychain" do
      before { FastlaneCore::StoredPasswords.reset_warnings! }

      it "does not store the passphrase unless asked to" do
        expect(Security::InternetPassword).not_to receive(:add)
        @e.store_password("new passphrase")
      end

      it "stores the passphrase when FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN is set" do
        stub_const('ENV', { "FASTLANE_STORE_PASSWORDS_IN_KEYCHAIN" => "1" })
        expect(Security::InternetPassword).to receive(:add).with("match_#{@git_url}", "", "new passphrase")
        @e.store_password("new passphrase")
      end

      it "warns once that a stored passphrase was read" do
        stub_const('ENV', {})
        allow(Security::InternetPassword).to receive(:find).with(server: "match_#{@git_url}").and_return(double("item", password: "stored passphrase"))
        allow(FastlaneCore::UI).to receive(:important)
        expect(FastlaneCore::UI).to receive(:important).with(/any program running as you can read/).once

        expect(@e.send(:fetch_password!)).to eq("stored passphrase")
        @e.send(:fetch_password!)
      end
    end
  end
end
