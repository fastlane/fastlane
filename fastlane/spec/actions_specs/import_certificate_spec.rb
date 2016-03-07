describe Fastlane do
  describe Fastlane::FastFile do
    describe "Import certificate Integration" do
      it "works with certificate and password" do
        result = Fastlane::FastFile.new.parse("lane :test do
          import_certificate ({
            keychain_name: 'test.keychain',
            certificate_path: 'test.cer',
            certificate_password: 'testpassword'
          })
        end").runner.execute(:test)

        expect(result).to start_with 'security'
        expect(result).to include 'import test.cer'
        expect(result).to include '-k ~/Library/Keychains/test.keychain'
        expect(result).to include '-P testpassword'
        expect(result).to include '-T /usr/bin/codesign'
        expect(result).to include '-T /usr/bin/security'
      end

      it "works with certificate and password that contain spaces or `\"`" do
        result = Fastlane::FastFile.new.parse("lane :test do
          import_certificate ({
            keychain_name: '\" test \".keychain',
            certificate_path: '\" test \".cer',
            certificate_password: '\"test password\"'
          })
        end").runner.execute(:test)

        expect(result).to start_with 'security'
        expect(result).to include %(import \\\"\\ test\\ \\\".cer)
        expect(result).to include %(-k ~/Library/Keychains/\\\"\\ test\\ \\\".keychain)
        expect(result).to include %(-P \\\"test\\ password\\\")
        expect(result).to include '-T /usr/bin/codesign'
        expect(result).to include '-T /usr/bin/security'
      end

      it "works with certificate" do
        result = Fastlane::FastFile.new.parse("lane :test do
          import_certificate ({
            keychain_name: 'test.keychain',
            certificate_path: 'test.cer',
          })
        end").runner.execute(:test)

        expect(result).to start_with 'security'
        expect(result).to include 'import test.cer'
        expect(result).to include '-k ~/Library/Keychains/test.keychain'
        expect(result).to_not include '-P'
        expect(result).to include '-T /usr/bin/codesign'
        expect(result).to include '-T /usr/bin/security'
      end
    end
  end
end
