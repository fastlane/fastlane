describe Match::Encryption do
  describe "for_storage_mode" do
    it "returns nil if storage mode is google_cloud" do
      storage_mode = "google_cloud"

      encryption = Match::Encryption.for_storage_mode(storage_mode, {
        git_url: "",
        s3_bucket: "",
        s3_skip_encryption: false,
        working_directory: ""
      })

      expect(encryption).to be_nil
    end

    it "returns nil if storage mode is gitlab_secure_files" do
      storage_mode = "gitlab_secure_files"

      encryption = Match::Encryption.for_storage_mode(storage_mode, {
        git_url: "",
        s3_bucket: "",
        s3_skip_encryption: false,
        working_directory: ""
      })

      expect(encryption).to be_nil
    end

    it "returns nil if storage mode is s3 and skip encryption is true" do
      storage_mode = "s3"

      encryption = Match::Encryption.for_storage_mode(storage_mode, {
        git_url: "",
        s3_bucket: "my-bucket",
        s3_skip_encryption: true,
        working_directory: ""
      })

      expect(encryption).to be_nil
    end

    it "should return OpenSSL object for storage mode git" do
      storage_mode = "git"
      git_url = "git@github.com:you/your_repo.git"
      working_directory = "my-working-directory"

      encryption = Match::Encryption.for_storage_mode(storage_mode, {
        git_url: git_url,
        s3_bucket: "",
        s3_skip_encryption: false,
        working_directory: working_directory
      })

      expect(encryption).to_not(be_nil)
      expect(encryption).to be_kind_of(Match::Encryption::OpenSSL)
      expect(encryption.keychain_name).to be(git_url)
      expect(encryption.working_directory).to be(working_directory)
    end

    it "should return OpenSSL object for storage mode s3 and skip encryption is false" do
      storage_mode = "s3"
      s3_bucket = "my-bucket"
      working_directory = "my-working-directory"

      encryption = Match::Encryption.for_storage_mode(storage_mode, {
        git_url: "",
        s3_bucket: s3_bucket,
        s3_skip_encryption: false,
        working_directory: working_directory
      })

      expect(encryption).to_not(be_nil)
      expect(encryption).to be_kind_of(Match::Encryption::OpenSSL)
      expect(encryption.keychain_name).to be(s3_bucket)
      expect(encryption.working_directory).to be(working_directory)
    end
  end
end
