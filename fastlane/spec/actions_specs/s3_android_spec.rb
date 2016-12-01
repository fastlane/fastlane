describe Fastlane::Actions::S3AndroidAction do
  describe "S3 Integration" do
    before(:each) do
      ['S3_ACCESS_KEY', 'S3_SECRET_ACCESS_KEY', 'S3_BUCKET', 'S3_REGION', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_BUCKET_NAME', 'AWS_REGION'].each do |key|
        ENV[key] = nil
      end
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::S3_APK_OUTPUT_PATH] = nil
      Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::S3_APK_HTML_OUTPUT_PATH] = nil
    end

    it "raise an error if no S3 access key was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        s3_android({})
        end").runner.execute(:test)
      end.to raise_error("No S3 access key given, pass using `access_key: 'key'`")
    end

    it "raise an error if no S3 secret access key was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        s3_android({
          access_key: 'access_key'
          })
        end").runner.execute(:test)
      end.to raise_error("No S3 secret access key given, pass using `secret_access_key: 'secret key'`")
    end

    it "raise an error if no S3 bucket was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        s3_android({
          access_key: 'access_key',
          secret_access_key: 'secret_access_key'
          })
        end").runner.execute(:test)
      end.to raise_error("No S3 bucket given, pass using `bucket: 'bucket'`")
    end

    it "raise an error if no APK was given" do
      expect do
        Fastlane::FastFile.new.parse("lane :test do
        s3_android({
          access_key: 'access_key',
          secret_access_key: 'secret_access_key',
          bucket: 'bucket'
          })
        end").runner.execute(:test)
      end.to raise_error("No APK file path given, pass using `apk: 'apk path'`")
    end
  end
end
