describe Fastlane do
  describe Fastlane::FastFile do
    describe "S3 Integration" do
      before(:each) do
        ['S3_ACCESS_KEY', 'S3_SECRET_ACCESS_KEY', 'S3_BUCKET', 'S3_REGION', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY', 'AWS_BUCKET_NAME', 'AWS_REGION'].each do |key|
          ENV[key] = nil
        end
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = nil
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = nil
      end

      it "raise an error if no S3 access key was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({})
          end").runner.execute(:test)
        end.to raise_error("No S3 access key given, pass using `access_key: 'key'`")
      end

      it "raise an error if no S3 secret access key was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({
              access_key: 'access_key'
              })
          end").runner.execute(:test)
        end.to raise_error("No S3 secret access key given, pass using `secret_access_key: 'secret key'`")
      end

      it "raise an error if no S3 bucket was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({
              access_key: 'access_key',
              secret_access_key: 'secret_access_key'
              })
          end").runner.execute(:test)
        end.to raise_error("No S3 bucket given, pass using `bucket: 'bucket'`")
      end

      it "raise an error if no IPA was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({
              access_key: 'access_key',
              secret_access_key: 'secret_access_key',
              bucket: 'bucket'
              })
          end").runner.execute(:test)
        end.to raise_error("No IPA file path given, pass using `ipa: 'ipa path'`")
      end

      it "raise an error if no IPA was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({
              access_key: 'access_key',
              secret_access_key: 'secret_access_key',
              bucket: 'bucket'
              })
          end").runner.execute(:test)
        end.to raise_error("No IPA file path given, pass using `ipa: 'ipa path'`")
      end
    end
  end
end
