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
        end.to raise_error("No S3 access key given, pass using `access_key: 'key'`".red)
      end

      it "raise an error if no S3 secret access key was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({
              access_key: 'access_key'
              })
          end").runner.execute(:test)
        end.to raise_error("No S3 secret access key given, pass using `secret_access_key: 'secret key'`".red)
      end

      it "raise an error if no S3 bucket was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            s3({
              access_key: 'access_key',
              secret_access_key: 'secret_access_key'
              })
          end").runner.execute(:test)
        end.to raise_error("No S3 bucket given, pass using `bucket: 'bucket'`".red)
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
        end.to raise_error("No IPA file path given, pass using `ipa: 'ipa path'`".red)
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
        end.to raise_error("No IPA file path given, pass using `ipa: 'ipa path'`".red)
      end

      it "works with required arguments" do
        result = Fastlane::FastFile.new.parse("lane :test do
          s3({
              access_key: 'access_key',
              secret_access_key: 'secret_access_key',
              bucket: 'bucket',
              ipa: 'ipa'
              })
        end").runner.execute(:test)

        expect(result.size).to eq(5) # 5 because path is defaulted
        expect(result).to include('-a "access_key"')
        expect(result).to include('-s "secret_access_key"')
        expect(result).to include('-b "bucket"')
        expect(result).to include('-f "ipa"')
        expect(result).to include('-P "v{CFBundleShortVersionString}_b{CFBundleVersion}/"')
      end

      it "works with required arguments and dsym and path" do
        result = Fastlane::FastFile.new.parse("lane :test do
          s3({
              access_key: 'access_key',
              secret_access_key: 'secret_access_key',
              bucket: 'bucket',
              ipa: 'ipa',
              dsym: 'dsym',
              path: './'
              })
        end").runner.execute(:test)

        expect(result.size).to eq(6) # 6 because path is defaulted
        expect(result).to include('-a "access_key"')
        expect(result).to include('-s "secret_access_key"')
        expect(result).to include('-b "bucket"')
        expect(result).to include('-f "ipa"')
        expect(result).to include('-d "dsym"')
        expect(result).to include('-P "./"')
      end

      it "works with upload_metadata argument as false" do
        # Environment variables
        ENV['S3_ACCESS_KEY'] = 'access_key'
        ENV['S3_SECRET_ACCESS_KEY'] = 'secret_access_key'
        ENV['S3_BUCKET'] = 'bucket'

        # IPA Action
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = 'ipa'
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = 'dsym'

        result = Fastlane::FastFile.new.parse("lane :test do
          s3({
            upload_metadata: false
          })
        end").runner.execute(:test)

        expect(result.size).to eq(6) # 6 because path is defaulted
        expect(result).to include('-a "access_key"')
        expect(result).to include('-s "secret_access_key"')
        expect(result).to include('-b "bucket"')
        expect(result).to include('-f "ipa"')
        expect(result).to include('-d "dsym"')
        expect(result).to include('-P "v{CFBundleShortVersionString}_b{CFBundleVersion}/"')
      end

      it "works with no arguments (magic variables)" do
        # Environment variables
        ENV['S3_ACCESS_KEY'] = 'access_key'
        ENV['S3_SECRET_ACCESS_KEY'] = 'secret_access_key'
        ENV['S3_BUCKET'] = 'bucket'

        # IPA Action
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] = 'ipa'
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::DSYM_OUTPUT_PATH] = 'dsym'

        result = Fastlane::FastFile.new.parse("lane :test do
          s3({})
        end").runner.execute(:test)

        expect(result.size).to eq(6) # 6 because path is defaulted
        expect(result).to include('-a "access_key"')
        expect(result).to include('-s "secret_access_key"')
        expect(result).to include('-b "bucket"')
        expect(result).to include('-f "ipa"')
        expect(result).to include('-d "dsym"')
        expect(result).to include('-P "v{CFBundleShortVersionString}_b{CFBundleVersion}/"')
      end
    end
  end
end
