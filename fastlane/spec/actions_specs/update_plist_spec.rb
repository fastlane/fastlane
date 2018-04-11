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
            block: lambda { |plist|
              plist['CFBundleIdentifier'] = '#{app_identifier}'
              plist['CFBundleDisplayName'] = '#{display_name}'
            }
          })
        end").runner.execute(:test)
        expect(result).to include("<string>#{display_name}</string>")
        expect(result).to include("<string>#{app_identifier}</string>")
      end

      it "throws an error when the plist file does not exist" do
        # This is path update_plist creates to locate the plist file.
        full_path = [test_path, proj_file, '..', "NOEXIST-#{plist_path}"].join(File::SEPARATOR)

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            update_plist ({
              plist_path: 'NOEXIST-#{plist_path}',
              block: lambda { |plist|
                plist['CFBundleDisplayName'] = '#{app_identifier}'
              }
            })
          end").runner.execute(:test)
        end.to raise_error("Couldn't find plist file at path 'NOEXIST-#{plist_path}'")
      end

      it "returns 'false' if no plist parameters are specified" do
        result = Fastlane::FastFile.new.parse("lane :test do
          update_plist ({
            plist_path: 'NOEXIST-#{plist_path}'
          })
        end").runner.execute(:test)
        expect(result).to eq(false)
      end

      after do
        # Clean up files
        File.delete(File.join(test_path, plist_path))
      end
    end
  end
end
