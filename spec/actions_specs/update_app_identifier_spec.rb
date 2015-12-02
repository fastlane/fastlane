require 'xcodeproj'
include Xcodeproj

module Xcodeproj
  class Project
  end
end

describe Fastlane do
  describe Fastlane::FastFile do
    describe "Update App Identifier Integration" do
      # Variables
      let (:test_path) { "/tmp/fastlane/tests/fastlane" }
      let (:fixtures_path) { "./spec/fixtures/xcodeproj" }
      let (:proj_file) { "bundle.xcodeproj" }
      let (:identifier_key) { 'PRODUCT_BUNDLE_IDENTIFIER' }

      # Action parameters
      let (:xcodeproj) { File.join(test_path, proj_file) }
      let (:plist_path) { "Info.plist" }
      let (:app_identifier) { "com.test.plist" }

      # Is there a better place for an helper function?
      # Create an Info.plist file with a supplied bundle_identifier parameter
      def create_plist_with_identifier(bundle_identifier)
        File.write(File.join(test_path, plist_path), "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>CFBundleIdentifier</key><string>#{bundle_identifier}</string></dict></plist>")
      end

      before do
        # Create test folder
        FileUtils.mkdir_p(test_path)
        source = File.join(fixtures_path, proj_file)
        destination = File.join(test_path, proj_file)

        # Copy .xcodeproj fixture, as it will be modified during the test
        FileUtils.cp_r(source, destination)
      end

      it "updates the info plist when product bundle identifier not in use" do
        plist = create_plist_with_identifier('tools.fastlane.example')

        Fastlane::FastFile.new.parse("lane :test do
          update_app_identifier ({
            xcodeproj: '#{xcodeproj}',
            plist_path: '#{plist_path}',
            app_identifier: '#{app_identifier}'
          })
        end").runner.execute(:test)

        result = File.read(File.join(test_path, plist_path))
        expect(result).to include("<string>#{app_identifier}</string>")
      end

      it "updates the xcode project when product bundle identifier in use" do
        stub_project = 'stub project'
        stub_configuration = 'stub config'
        stub_object = ['object']
        stub_settings = Hash['PRODUCT_BUNDLE_IDENTIFIER', 'com.something.else']

        expect(Xcodeproj::Project).to receive(:open).with('/tmp/fastlane/tests/fastlane/bundle.xcodeproj').and_return(stub_project)
        expect(stub_project).to receive(:objects).and_return(stub_object)
        expect(stub_object).to receive(:select).and_return([stub_configuration])
        expect(stub_configuration).to receive(:build_settings).and_return(stub_settings)
        expect(stub_project).to receive(:save)

        create_plist_with_identifier("$(#{identifier_key})")
        Fastlane::FastFile.new.parse("lane :test do
          update_app_identifier ({
            xcodeproj: '#{xcodeproj}',
            plist_path: '#{plist_path}',
            app_identifier: '#{app_identifier}'
          })
        end").runner.execute(:test)

        expect(stub_settings['PRODUCT_BUNDLE_IDENTIFIER']).to eq('com.test.plist')
      end

      it "should raise an exception when PRODUCT_BUNDLE_IDENTIFIER in info plist but not project" do
        stub_project = 'stub project'
        stub_configuration = 'stub config'
        stub_object = ['object']

        expect(Xcodeproj::Project).to receive(:open).with('/tmp/fastlane/tests/fastlane/bundle.xcodeproj').and_return(stub_project)
        expect(stub_project).to receive(:objects).and_return(stub_object)
        expect(stub_object).to receive(:select).and_return([])

        create_plist_with_identifier("$(#{identifier_key})")
        expect do
          Fastlane::FastFile.new.parse("lane :test do
          update_app_identifier ({
            xcodeproj: '#{xcodeproj}',
            plist_path: '#{plist_path}',
            app_identifier: '#{app_identifier}'
          })
          end").runner.execute(:test)
        end.to raise_error("Info plist uses $(#{identifier_key}), but xcodeproj does not".red)
      end

      after do
        # Clean up files
        FileUtils.rm_r(test_path)
      end
    end
  end
end
