describe Fastlane do
  describe Fastlane::FastFile do
    describe "Backup xcarchive Integration" do
      let(:tmp_path) { Dir.mktmpdir }
      let(:source_path) { "#{tmp_path}/fastlane" }
      let(:destination_path) { "#{source_path}/dest" }
      let(:xcarchive_file) { "fake.xcarchive" }
      let(:zip_file) { "fake.xcarchive.zip" }
      let(:source_xcarchive_path) { "#{source_path}/#{xcarchive_file}" }
      let(:file_content) { Time.now.to_s }

      context "plain backup" do
        before :each do
          FileUtils.mkdir_p(source_path)
          FileUtils.mkdir_p(destination_path)
          File.write(File.join(source_path, xcarchive_file), file_content)
        end

        it "copy xcarchive to destination" do
          result = Fastlane::FastFile.new.parse("lane :test do
              backup_xcarchive(
                  versioned: false,
                  xcarchive: '#{source_xcarchive_path}',
                  destination: '#{destination_path}',
                  zip: false)
          end").runner.execute(:test)

          expect(File.exist?(File.join(destination_path, xcarchive_file))).to eq(true)
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BACKUP_XCARCHIVE_FILE]).to eq(File.join(destination_path, xcarchive_file))
        end

        after :each do
          File.delete(File.join(source_path, xcarchive_file))
          File.delete(File.join(destination_path, xcarchive_file))
        end
      end

      context "zipped backup" do
        before :each do
          FileUtils.mkdir_p(source_path)
          FileUtils.mkdir_p(destination_path)
          File.write(File.join(source_path, xcarchive_file), file_content)
          File.write(File.join(tmp_path, zip_file), file_content)
          expect(Dir).to receive(:mktmpdir).with("backup_xcarchive").and_yield(tmp_path)
        end

        it "make and copy zip to destination" do
          result = Fastlane::FastFile.new.parse("lane :test do
              backup_xcarchive(
                  versioned: false,
                  xcarchive: '#{source_xcarchive_path}',
                  destination: '#{destination_path}',
                  zip: true
                  )
          end").runner.execute(:test)

          expect(File.exist?(File.join(destination_path, zip_file))).to eq(true)
          expect(Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::BACKUP_XCARCHIVE_FILE]).to eq(File.join(destination_path, zip_file))
        end

        after :each do
          File.delete(File.join(source_path, xcarchive_file))
          File.delete(File.join(destination_path, zip_file))
        end
      end

      context "zipped backup with custom filename" do
        let(:custom_zip_filename) { "App_1.0.0" }
        let(:zip_file) { "#{custom_zip_filename}.xcarchive.zip" }
        before :each do
          FileUtils.mkdir_p(source_path)
          FileUtils.mkdir_p(destination_path)
          File.write(File.join(source_path, xcarchive_file), file_content)
          File.write(File.join(tmp_path, zip_file), file_content)
          expect(Dir).to receive(:mktmpdir).with("backup_xcarchive").and_yield(tmp_path)
        end

        it "make zip with custom filename and copy to destination" do
          allow(Fastlane::Actions).to receive(:sh).with("cd \"#{source_path}\" && zip -r -X -y \"#{tmp_path}/#{custom_zip_filename}.xcarchive.zip\" \"#{xcarchive_file}\" > /dev/null").and_return("")
          result = Fastlane::FastFile.new.parse("lane :test do
            backup_xcarchive(
              versioned: false,
              xcarchive: '#{source_xcarchive_path}',
              destination: '#{destination_path}',
              zip: true,
              zip_filename: '#{custom_zip_filename}'
            )
          end").runner.execute(:test)
        end

        after :each do
          File.delete(File.join(source_path, xcarchive_file))
          File.delete(File.join(destination_path, zip_file))
        end
      end

      context "versioned backup" do
        # The project directory has no fastlane folder, so the action runs in it and finds the project.
        let(:project_path) { Dir.mktmpdir }
        let(:destination_path) { File.join(project_path, "dest") }
        let(:source_xcarchive_path) { File.join(project_path, xcarchive_file) }

        it "copies the xcarchive into a folder named after the date and the app version" do
          FileUtils.mkdir_p(destination_path)
          File.write(source_xcarchive_path, file_content)
          create_versioning_project(project_path, info_plist: { "CFBundleShortVersionString" => "1.2.3" })

          Dir.chdir(project_path) do
            Fastlane::FastFile.new.parse("lane :test do
              backup_xcarchive(
                xcarchive: '#{source_xcarchive_path}',
                destination: '#{destination_path}',
                zip: false
              )
            end").runner.execute(:test)
          end

          versioned_path = File.join(destination_path, "#{Time.now.strftime('%Y-%m-%d')} 1.2.3")
          expect(File.exist?(File.join(versioned_path, xcarchive_file))).to eq(true)
        end
      end
    end
  end
end
