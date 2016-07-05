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
    end
  end
end

describe Fastlane::Actions::S3Action do
  describe '#icon_files' do
    it "should get icons from ipa" do
      info = FastlaneCore::IpaFileAnalyser.fetch_info_plist_file("spec/fixtures/ipas/iOSAppOnly.ipa")
      icons = Fastlane::Actions::S3Action.icon_files(info)
      expect(icons).to eq(["AppIcon29x29", "AppIcon40x40", "AppIcon57x57", "AppIcon60x60"])
    end
  end
  describe "#largest_icon" do
    class IconMock
      attr_reader :name
      def initialize(path)
        @name = path
      end
    end
    it "should order icons by size multiplier" do
      icon_files = [
        IconMock.new("/tmp/AppIcon60x60.png"),
        IconMock.new("/tmp/AppIcon60x60@2x.png"),
        IconMock.new("/tmp/AppIcon60x60@3x.png")
      ]
      icon = Fastlane::Actions::S3Action.largest_icon(icon_files)
      expect(icon).to eq(icon_files[2])
    end
    it "should pick first icon if there's no multiplier" do
      icon_files = [
        IconMock.new("/tmp/AppIcon60x60.png"),
        IconMock.new("/tmp/AppIcon60x61.png")
      ]
      icon = Fastlane::Actions::S3Action.largest_icon(icon_files)
      expect(icon).to eq(icon_files[0])
    end
  end
end
