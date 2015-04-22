describe Fastlane do
  describe Fastlane::FastFile do
    describe "Create dSYM zip" do
      xcodebuild_archive = 'MyApp.xcarchive'

      before :each do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::XCODEBUILD_ARCHIVE] = xcodebuild_archive
      end

      it "creates a zip file with default archive_path from xcodebuild" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          dsym_zip
        end").runner.execute(:test)

        dsym_folder_path = File.expand_path(File.join(xcodebuild_archive, 'dSYMs'))
        zipped_dsym_path = File.expand_path(File.join("#{File.basename(xcodebuild_archive, '.*')}.app.dSYM.zip"))

        expect(result).to eq(%Q[cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "MyApp.app.dSYM"])
      end

      it "creates a zip file with a custom archive_path" do
        result = Fastlane::FastFile.new.parse("lane :test do 
          dsym_zip(
            archive_path: 'MyApp.xcarchive'
          )
        end").runner.execute(:test)

        dsym_folder_path = File.expand_path(File.join(xcodebuild_archive, 'dSYMs'))
        zipped_dsym_path = File.expand_path(File.join("#{File.basename(xcodebuild_archive, '.*')}.app.dSYM.zip"))

        expect(result).to eq(%Q[cd "#{dsym_folder_path}" && zip -r "#{zipped_dsym_path}" "MyApp.app.dSYM"])
      end
    end
  end
end
