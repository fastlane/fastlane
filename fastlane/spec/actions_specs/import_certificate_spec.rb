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

      it "works with a boolean for log_output" do
        result = Fastlane::FastFile.new.parse("lane :test do
          import_certificate ({
            keychain_name: '\" test \".keychain',
            certificate_path: '\" test \".cer',
            certificate_password: '\"test password\"',
            log_output: true
          })
        end").runner.execute(:test)

        expect(result).to start_with 'security'
        expect(result).to include %(import \\\"\\ test\\ \\\".cer)
        expect(result).to include %(-k ~/Library/Keychains/\\\"\\ test\\ \\\".keychain)
        expect(result).to include %(-P \\\"test\\ password\\\")
        expect(result).to include '-T /usr/bin/codesign'
        expect(result).to include '-T /usr/bin/security'
      end

      it "does not work with a string for log_output" do
        import_certificate_fastfile = "lane :test do
          import_certificate ({
            keychain_name: '\" test \".keychain',
            certificate_path: '\" test \".cer',
            certificate_password: '\"test password\"',
            log_output: '\"true\"'
          })
        end"

        expect { Fastlane::FastFile.new.parse(import_certificate_fastfile).runner.execute(:test) }.to(
          raise_error(FastlaneCore::Interface::FastlaneError) do |error|
            expect(error.message).to match(/'log_output' value must be a TrueClass! Found String instead/)
          end
        )
      end
    end
  end
end
