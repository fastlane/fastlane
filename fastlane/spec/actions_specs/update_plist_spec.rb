describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Plist Integration" do
      let(:test_path) { "/tmp/fastlane/tests/fastlane" }
      let(:fixtures_path) { "./fastlane/spec/fixtures/xcodeproj" }
      let(:proj_file) { "bundle.xcodeproj" }
      let(:plist_path) { "Info.plist" }
      let(:app_identifier) { "com.test.plist" }
      let(:display_name) { "Update Info Plist Test" }

      before do
        # Set up example info.plist
        FileUtils.mkdir_p(test_path)
        source = File.join(fixtures_path, proj_file)
        destination = File.join(test_path, proj_file)

        # Copy .xcodeproj fixture, as it will be modified during the test
        FileUtils.cp_r(source, destination)
        File.write(File.join(test_path, plist_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleDisplayName</key><string>empty</string><key>CFBundleIdentifier</key><string>empty</string></dict></plist>')
      end

      it "updates the plist based on the given block" do
        result = Fastlane::FastFile.new.parse("lane :test do
          update_plist ({
            plist_path: '#{test_path}/#{plist_path}',
            block: proc do |plist|
              plist['CFBundleIdentifier'] = '#{app_identifier}'
              plist['CFBundleDisplayName'] = '#{display_name}'
            end
          })
        end").runner.execute(:test)
        expect(result).to include("<string>#{display_name}</string>")
        expect(result).to include("<string>#{app_identifier}</string>")
      end

      it "updates the plist using symbol keys" do
        result = Fastlane::FastFile.new.parse("lane :test do
          update_plist ({
            plist_path: '#{test_path}/#{plist_path}',
            block: proc do |plist|
              plist[:CFBundleIdentifier] = '#{app_identifier}'
              plist[:CFBundleDisplayName] = '#{display_name}'
            end
          })
        end").runner.execute(:test)
        expect(result).to include("<string>#{display_name}</string>")
        expect(result).to include("<string>#{app_identifier}</string>")
      end

      it "updates the plist with mixed symbol and string keys" do
        result = Fastlane::FastFile.new.parse("lane :test do
          update_plist ({
            plist_path: '#{test_path}/#{plist_path}',
            block: proc do |plist|
              plist[:CFBundleIdentifier] = '#{app_identifier}'
              plist['CFBundleDisplayName'] = '#{display_name}'
            end
          })
        end").runner.execute(:test)
        expect(result).to include("<string>#{display_name}</string>")
        expect(result).to include("<string>#{app_identifier}</string>")
      end

      it "updates the plist with symbol keys for large plist files" do
        # Create a large plist with many keys to reproduce the issue
        large_plist_keys = (1..40).map { |i| "<key>Key#{i}</key><string>Value#{i}</string>" }.join
        large_plist_content = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict>' + large_plist_keys + '<key>CFBundleIdentifier</key><string>empty</string></dict></plist>'

        large_plist_path = File.join(test_path, 'LargeInfo.plist')
        File.write(large_plist_path, large_plist_content)

        begin
          result = Fastlane::FastFile.new.parse("lane :test do
            update_plist ({
              plist_path: '#{large_plist_path}',
              block: proc do |plist|
                plist[:CFBundleIdentifier] = '#{app_identifier}'
              end
            })
          end").runner.execute(:test)
          expect(result).to include("<string>#{app_identifier}</string>")
        ensure
          File.delete(large_plist_path) if File.exist?(large_plist_path)
        end
      end

      it "throws an error when the plist file does not exist" do
        # This is path update_plist creates to locate the plist file.
        full_path = [test_path, proj_file, '..', "NOEXIST-#{plist_path}"].join(File::SEPARATOR)

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            update_plist ({
              plist_path: 'NOEXIST-#{plist_path}',
              block: proc do |plist|
                plist['CFBundleDisplayName'] = '#{app_identifier}'
              end
            })
          end").runner.execute(:test)
        end.to raise_error("Couldn't find plist file at path 'NOEXIST-#{plist_path}'")
      end

      after do
        # Clean up files
        File.delete(File.join(test_path, plist_path))
      end
    end
  end
end
