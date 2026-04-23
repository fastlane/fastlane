require 'deliver/detect_values'

describe Deliver::DetectValues do
  let(:value_detector) { Deliver::DetectValues.new }

  describe :find_folders do
    describe 'when folders are not specified in options' do
      let(:options) { { screenshots_path: nil, metadata_path: nil } }

      describe 'running with fastlane' do
        before do
          allow(FastlaneCore::Helper).to receive(:fastlane_enabled?).and_return(true)
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return('./fastlane')
        end

        it 'sets up screenshots folder in fastlane folder' do
          value_detector.find_folders(options)
          expect(options[:screenshots_path]).to eq('./fastlane/screenshots')
        end

        it 'sets up metadata folder in fastlane folder' do
          value_detector.find_folders(options)
          expect(options[:metadata_path]).to eq('./fastlane/metadata')
        end

        it 'does not automatically set up app previews folder in fastlane folder even if it exists' do
          FileUtils.mkdir_p('./fastlane/app-previews')
          value_detector.find_folders(options)
          expect(options[:app_previews_path]).to be_nil
          FileUtils.rm_rf('./fastlane/app-previews')
        end
      end

      describe 'running without fastlane' do
        before do
          allow(FastlaneCore::Helper).to receive(:fastlane_enabled?).and_return(false)
        end

        it 'sets up screenshots folder in current folder' do
          value_detector.find_folders(options)
          expect(options[:screenshots_path]).to eq('./screenshots')
        end

        it 'sets up metadata folder in current folder' do
          value_detector.find_folders(options)
          expect(options[:metadata_path]).to eq('./metadata')
        end

        it 'does not automatically set up app previews folder in current folder even if it exists' do
          FileUtils.mkdir_p('./app-previews')
          value_detector.find_folders(options)
          expect(options[:app_previews_path]).to be_nil
          FileUtils.rm_rf('./app-previews')
        end
      end
    end

    describe 'when folders are specified in options' do
      let(:options) { { screenshots_path: './screenshots', metadata_path: './metadata', app_previews_path: './app-previews' } }

      it 'keeps the specified screenshots folder' do
        expect(options[:screenshots_path]).to eq('./screenshots')
      end

      it 'keeps the specified metadata folder' do
        expect(options[:metadata_path]).to eq('./metadata')
      end

      it 'keeps the specified app previews folder' do
        expect(options[:app_previews_path]).to eq('./app-previews')
      end
    end
  end
end
