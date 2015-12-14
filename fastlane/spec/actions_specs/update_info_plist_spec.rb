describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Info Plist Integration" do
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:xcodeproj) { "/tmp/fastlane/tests/fastlane/Test.xcodeproj" }
      let (:plist_path) { "com.test.plist" }
      let (:app_identifier) { "com.test.plist" }
      let (:display_name) { "Update Info Plist Test" }

      before do
        # Set up example info.plist
        FileUtils.mkdir_p(test_path)
        FileUtils.mkdir_p(xcodeproj)
        File.write(File.join(test_path, plist_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>CFBundleDisplayName</key><string>empty</string><key>CFBundleIdentifier</key><string>empty</string></dict></plist>')
      end

      it "updates the info plist based on the given properties" do
        result = Fastlane::FastFile.new.parse("lane :test do
          update_info_plist ({
            xcodeproj: '#{xcodeproj}',
            plist_path: '#{plist_path}',
            app_identifier: '#{app_identifier}',
            display_name: '#{display_name}'
          })
        end").runner.execute(:test)
        expect(result).to include("<string>#{display_name}</string>")
        expect(result).to include("<string>#{app_identifier}</string>")
      end

      it "throws an error when the info plist file does not exist" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            update_info_plist ({
              xcodeproj: '#{xcodeproj}',
              plist_path: 'NOEXIST-#{plist_path}',
              app_identifier: '#{app_identifier}',
              display_name: '#{display_name}'
            })
          end").runner.execute(:test)
        end.to raise_error("Couldn't find info plist file at path 'NOEXIST-#{plist_path}'".red)
      end

      it "returns 'false' if no plist parameters are specified" do
        result = Fastlane::FastFile.new.parse("lane :test do
          update_info_plist ({
            xcodeproj: '#{xcodeproj}',
            plist_path: 'NOEXIST-#{plist_path}'
          })
        end").runner.execute(:test)
        expect(result).to eq false
      end

      after do
        # Clean up files
        File.delete(File.join(test_path, plist_path))
        FileUtils.rm_rf(xcodeproj)
      end
    end
  end
end
