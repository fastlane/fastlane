describe Fastlane do
  describe Fastlane::FastFile do
    describe "Upload folder to S3" do
      before(:each) do
        ['FL_UPLOAD_FOLDER_TO_S3_ACCESS_KEY_ID', 'FL_UPLOAD_FOLDER_TO_S3_SECRET_ACCESS_KEY', 'FL_UPLOAD_FOLDER_TO_S3_REGION', 'FL_UPLOAD_FOLDER_TO_S3_BUCKET', 'FL_UPLOAD_FOLDER_TO_S3_LOCAL_PATH', 'FL_UPLOAD_FOLDER_TO_S3_REMOTE_PATH'].each do |key|
          ENV[key] = nil
        end
        @dumb_config = {secret_access_key: 'secret', access_key_id: 'id', local_path: '/tmp', remote_path: 'whatever', region: 'region', bucket: 'bucket'}
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::UPLOAD_FOLDER_TO_S3_RESULT] = nil
      end

      it "raise an error if no S3 secret access key was given" do
        expect do
          @dumb_config[:secret_access_key] = nil
          Fastlane::FastFile.new.parse("lane :test do
            upload_folder_to_s3(#{@dumb_config})
          end").runner.execute(:test)
        end.to raise_error(Fastlane::Actions::UploadFolderToS3Action.no_secret_access_key_error_message)
      end

      it "raise an error if no S3 access key ID was given" do
        expect do
          @dumb_config[:access_key_id] = nil
          Fastlane::FastFile.new.parse("lane :test do
            upload_folder_to_s3(#{@dumb_config})
          end").runner.execute(:test)
        end.to raise_error(Fastlane::Actions::UploadFolderToS3Action.no_access_key_id_error_message)
      end

      it "raise an error if no S3 region was given" do
        expect do
          @dumb_config[:region] = nil
          Fastlane::FastFile.new.parse("lane :test do
            upload_folder_to_s3(#{@dumb_config})
          end").runner.execute(:test)
        end.to raise_error(Fastlane::Actions::UploadFolderToS3Action.no_region_error_message)
      end

      it "raise an error if no S3 bucket was given" do
        expect do
          @dumb_config[:bucket] = nil
          Fastlane::FastFile.new.parse("lane :test do
            upload_folder_to_s3(#{@dumb_config})
          end").runner.execute(:test)
        end.to raise_error(Fastlane::Actions::UploadFolderToS3Action.no_bucket_error_message)
      end

      it "raise an error if no valid local path was given" do
        expect do
          @dumb_config[:local_path] = nil
          Fastlane::FastFile.new.parse("lane :test do
            upload_folder_to_s3(#{@dumb_config})
          end").runner.execute(:test)
        end.to raise_error(Fastlane::Actions::UploadFolderToS3Action.invalid_local_folder_path_message)
      end

      it "raise an error if no valid remote path was given" do
        expect do
          @dumb_config[:remote_path] = nil
          Fastlane::FastFile.new.parse("lane :test do
            upload_folder_to_s3(#{@dumb_config})
          end").runner.execute(:test)
        end.to raise_error(Fastlane::Actions::UploadFolderToS3Action.invalid_remote_folder_path_message)
      end
    end
  end
end
