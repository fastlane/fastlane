describe Fastlane do
  describe Fastlane::FastFile do
    describe "S3 Integration" do
      it "raise an error to use S3 plugin" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({})
          end").runner.execute(:test)
        end.to raise_error("Please use the `aws_s3` plugin instead. Install using `fastlane add_plugin aws_s3`.")
      end
    end
  end
end
