describe Fastlane do
  describe Fastlane::FastFile do
    describe "Backup xcarchive Integration" do
      let(:tmp_path) { "/tmp/fastlane/tests" }
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
    end
  end
end
