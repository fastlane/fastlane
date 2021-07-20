describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update Info Plist Integration" do
      let(:test_path) { "/tmp/fastlane/tests/fastlane" }
      let(:entitlements_path) { "com.test.entitlements" }
      let(:new_app_group) { 'group.com.enterprise.test' }

      before do
        # Set up example info.plist
        FileUtils.mkdir_p(test_path)
        File.write(File.join(test_path, entitlements_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>com.apple.security.application-groups</key><array><string>group.com.test</string></array></dict></plist>')
      end

      it "updates the app group of the entitlements file" do
        result = Fastlane::FastFile.new.parse("lane :test do

          update_app_group_identifiers(
            entitlements_file: '#{File.join(test_path, entitlements_path)}',
            app_group_identifiers: ['#{new_app_group}']
          )
        end").runner.execute(:test)
        expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::APP_GROUP_IDENTIFIERS]).to match([new_app_group])
      end

      it "throws an error when the entitlements file does not exist" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          update_app_group_identifiers(
            entitlements_file: 'xyz.#{File.join(test_path, entitlements_path)}',
            app_group_identifiers: ['#{new_app_group}']
          )
          end").runner.execute(:test)
        end.to raise_error("Could not find entitlements file at path 'xyz.#{File.join(test_path, entitlements_path)}'")
      end

      it "throws an error when the identifiers are not in an array" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          update_app_group_identifiers(
            entitlements_file: '#{File.join(test_path, entitlements_path)}',
            app_group_identifiers: '#{new_app_group}'
          )
          end").runner.execute(:test)
        end.to raise_error('The parameter app_group_identifiers need to be an Array.')
      end

      it "throws an error when the entitlements file is not parsable" do
        File.write(File.join(test_path, entitlements_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict><key>com.apple.security.application-groups</key><array><string>group.com.</array></dict></plist>')

        expect do
          Fastlane::FastFile.new.parse("lane :test do
          update_app_group_identifiers(
            entitlements_file: '#{File.join(test_path, entitlements_path)}',
            app_group_identifiers: ['#{new_app_group}']
          )
          end").runner.execute(:test)
        end.to raise_error("Entitlements file at '#{File.join(test_path, entitlements_path)}' cannot be parsed.")
      end

      it "throws an error when the entitlements file doesn't contain an app group" do
        File.write(File.join(test_path, entitlements_path), '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"><plist version="1.0"><dict></dict></plist>')

        expect do
          Fastlane::FastFile.new.parse("lane :test do
          update_app_group_identifiers(
            entitlements_file: '#{File.join(test_path, entitlements_path)}',
            app_group_identifiers: ['#{new_app_group}']
          )
          end").runner.execute(:test)
        end.to raise_error("No existing App group field specified. Please specify an App Group in the entitlements file.")
      end

      after do
        # Clean up files
        File.delete(File.join(test_path, entitlements_path))
      end
    end
  end
end
