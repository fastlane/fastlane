describe Fastlane do
  describe Fastlane::FastFile do
    describe "Import certificate Integration" do
      let(:cert_name) { "test.cer" }
      let(:keychain) { "test.keychain" }
      let(:keychain_path) { File.expand_path(File.join('~', 'Library', 'Keychains', keychain)) }
      let(:password) { "testpassword" }

      before(:each) do
        allow(File).to receive(:file?).and_call_original
        allow(File).to receive(:file?).with(keychain_path).and_return(true)
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(cert_name).and_return(true)
        allow(FastlaneCore::KeychainImporter).to receive(:resolve_keychain_password).and_return("")
      end

      def import_certificate(options)
        Fastlane::FastFile.new.parse("lane :test do
          import_certificate(#{options})
        end").runner.execute(:test)
      end

      it "imports into the named keychain, then sets the partition list" do
        expect(Security::Certificate).to receive(:import).with(cert_name, keychain: keychain_path, password: password, format: nil).and_return(true)
        expect(FastlaneCore::KeychainImporter).to receive(:set_partition_list).with(cert_name, keychain_path, keychain_password: "", output: false)

        import_certificate("keychain_name: '#{keychain}', certificate_path: '#{cert_name}', certificate_password: '#{password}'")
      end

      it "passes the certificate format" do
        expect(Security::Certificate).to receive(:import).with(cert_name, keychain: keychain_path, password: password, format: "pkcs12").and_return(true)
        allow(FastlaneCore::KeychainImporter).to receive(:set_partition_list)

        import_certificate("keychain_name: '#{keychain}', certificate_path: '#{cert_name}', certificate_password: '#{password}', certificate_format: 'pkcs12'")
      end

      it "passes paths and passwords containing spaces, quotes and dollars as they are" do
        tricky_cert = '" test ".cer'
        tricky_password = '"test pa$$word"'
        allow(File).to receive(:exist?).with(tricky_cert).and_return(true)

        expect(Security::Certificate).to receive(:import).with(tricky_cert, keychain: "/Volumes/SSD 500/test.keychain-db", password: tricky_password, format: nil).and_return(true)
        expect(FastlaneCore::KeychainImporter).to receive(:set_partition_list).with(tricky_cert, "/Volumes/SSD 500/test.keychain-db", keychain_password: tricky_password, output: false)

        FastlaneCore::KeychainImporter.import_file(tricky_cert, "/Volumes/SSD 500/test.keychain-db", keychain_password: tricky_password, certificate_password: tricky_password, output: false)
      end

      it "shows the command without the password when log_output is set" do
        allow(Security::Certificate).to receive(:import).and_return(true)
        allow(FastlaneCore::KeychainImporter).to receive(:set_partition_list)
        expect(FastlaneCore::UI).to receive(:command).with("security import #{cert_name} -k #{keychain_path.shellescape} -P ********")

        import_certificate("keychain_name: '#{keychain}', certificate_path: '#{cert_name}', certificate_password: '#{password}', log_output: true")
      end

      it "skips the partition list for a certificate already in the keychain" do
        allow(Security::Certificate).to receive(:import).and_raise(Security::DuplicateItemError.new(1, "security: SecKeychainItemImport: The specified item already exists in the keychain.\n"))
        expect(FastlaneCore::UI).to receive(:verbose).with("'#{cert_name}' is already installed on this machine")
        expect(FastlaneCore::KeychainImporter).not_to receive(:set_partition_list)

        FastlaneCore::KeychainImporter.import_file(cert_name, keychain_path, certificate_password: password)
      end

      it "reports any other failure and skips the partition list" do
        allow(Security::Certificate).to receive(:import).and_raise(Security::Error.new(1, "security: SecKeychainItemImport: Import/Export format unsupported.\n"))
        expect(FastlaneCore::UI).to receive(:error).with("security: SecKeychainItemImport: Import/Export format unsupported.")
        expect(FastlaneCore::KeychainImporter).not_to receive(:set_partition_list)

        FastlaneCore::KeychainImporter.import_file(cert_name, keychain_path, certificate_password: password)
      end

      it "skips the partition list when asked to" do
        allow(Security::Certificate).to receive(:import).and_return(true)
        expect(FastlaneCore::KeychainImporter).not_to receive(:set_partition_list)

        FastlaneCore::KeychainImporter.import_file(cert_name, keychain_path, certificate_password: password, skip_set_partition_list: true)
      end
    end
  end
end
