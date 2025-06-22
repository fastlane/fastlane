describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Info Plist Integration" do
      let(:test_path) { "/tmp/fastlane/tests/fastlane" }
      let(:entitlements_path) { "com.test.entitlements" }
      let(:new_keychain_access_groups) { 'keychain.access.groups.test' }

      before do
        # Set up example info.plist
        FileUtils.mkdir_p(test_path)
        File.write(File.join(test_path, entitlements_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>keychain-access-groups</key><array><string>keychain.access.groups.test</string></array></dict></plist>')
      end

      it "updates the keychain access groups of the entitlements file" do
        result = Fastlane::FastFile.new.parse("lane :test do
            update_keychain_access_groups(
            entitlements_file: '#{File.join(test_path, entitlements_path)}',
            identifiers: ['#{new_keychain_access_groups}']
          )
        end").runner.execute(:test)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::KEYCHAIN_ACCESS_GROUPS]).to match([new_keychain_access_groups])
      end

      it "throws an error when the entitlements file does not exist" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            update_keychain_access_groups(
            entitlements_file: 'abc.#{File.join(test_path, entitlements_path)}',
            identifiers: ['#{new_keychain_access_groups}']
          )
          end").runner.execute(:test)
        end.to raise_error("Could not find entitlements file at path 'abc.#{File.join(test_path, entitlements_path)}'")
      end

      it "throws an error when the entitlements file is not parsable" do
        File.write(File.join(test_path, entitlements_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>keychain-access-groups</key><array><string>keychain.access.groups.</array></dict></plist>')

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            update_keychain_access_groups(
            entitlements_file: '#{File.join(test_path, entitlements_path)}',
            identifiers: ['#{new_keychain_access_groups}']
          )
          end").runner.execute(:test)
        end.to raise_error("Entitlements file at '#{File.join(test_path, entitlements_path)}' cannot be parsed.")
      end

      it "throws an error when the entitlements file doesn't contain keychain access groups" do
        File.write(File.join(test_path, entitlements_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict></dict></plist>')

        expect do
          Fastlane::FastFile.new.parse("lane :test do
            update_keychain_access_groups(
            entitlements_file: '#{File.join(test_path, entitlements_path)}',
            identifiers: ['#{new_keychain_access_groups}']
          )
          end").runner.execute(:test)
        end.to raise_error("No existing keychain access groups field specified. Please specify an keychain access groups in the entitlements file.")
      end

      after do
        # Clean up files
        File.delete(File.join(test_path, entitlements_path))
      end
    end
  end
end
