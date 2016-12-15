describe Fastlane do
  describe Fastlane::FastFile do
    describe "Create dSYM zip" do
      xcodebuild_archive = 'MyApp.xcarchive'

      before(:each) do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::XCODEBUILD_ARCHIVE] = xcodebuild_archive
      end

      context "when there's no custom zip path" do
        result = nil

        before :each do
          result = Fastlane::FastFile.new.parse("lane :test do
            dsym_zip
          end").runner.execute(:test)
        end

        it "creates a zip file with default archive_path from xcodebuild" do
          # Move one folder above as specs are execute in fastlane folder
          root_path = File.expand_path(".")
          file_basename = File.basename(xcodebuild_archive, '.*')

          dsym_folder_path = File.join(root_path, File.join(xcodebuild_archive, 'dSYMs'))
          zipped_dsym_path = File.join(root_path, "#{file_basename}.app.dSYM.zip")

          expect(result).to eq(%(cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "MyApp.app.dSYM"))
        end
      end

      context "when there's a custom zip path" do
        result = nil

        before :each do
          result = Fastlane::FastFile.new.parse("lane :test do
            dsym_zip(
              archive_path: 'CustomApp.xcarchive'
            )
          end").runner.execute(:test)
        end

        it "creates a zip file with a custom archive path" do
          custom_app_path = 'CustomApp.xcarchive'

          # Move one folder above as specs are execute in fastlane folder
          root_path = File.expand_path(".")
          file_basename = File.basename(custom_app_path.to_s, '.*')

          dsym_folder_path = File.join(root_path, File.join(custom_app_path.to_s, 'dSYMs'))
          zipped_dsym_path = File.join(root_path, "#{file_basename}.app.dSYM.zip")

          # MyApp is hardcoded into tested class so we'll just use that here
          expect(result).to eq(%(cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "MyApp.app.dSYM"))
        end
      end

      context "when there's a custom dsym path" do
        result = nil

        before :each do
          result = Fastlane::FastFile.new.parse("lane :test do
            dsym_zip(
              dsym_path: 'CustomPath/MyApp.app.dSYM.zip'
            )
          end").runner.execute(:test)
        end

        it "creates a zip file with a custom dsym path" do
          # Move one folder above as specs are execute in fastlane folder
          root_path = File.expand_path(".")
          file_basename = File.basename(xcodebuild_archive, '.*')

          dsym_folder_path = File.join(root_path, File.join(xcodebuild_archive, 'dSYMs'))
          zipped_dsym_path = File.join(File.join(root_path, 'CustomPath'), "#{file_basename}.app.dSYM.zip")

          expect(result).to eq(%(cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "MyApp.app.dSYM"))
        end
      end
    end
  end
end
