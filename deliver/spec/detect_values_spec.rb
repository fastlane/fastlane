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

          value_detector.find_folders(options)
        end

        it 'sets up screenshots folder in fastlane folder' do
          expect(options[:screenshots_path]).to eq('./fastlane/screenshots')
        end

        it 'sets up metadata folder in fastlane folder' do
          expect(options[:metadata_path]).to eq('./fastlane/metadata')
        end
      end

      describe 'running without fastlane' do
        before do
          allow(FastlaneCore::Helper).to receive(:fastlane_enabled?).and_return(false)

          value_detector.find_folders(options)
        end

        it 'sets up screenshots folder in current folder' do
          expect(options[:screenshots_path]).to eq('./screenshots')
        end

        it 'sets up metadata folder in current folder' do
          expect(options[:metadata_path]).to eq('./metadata')
        end
      end
    end

    describe 'when folders are specified in options' do
      let(:options) { { screenshots_path: './screenshots', metadata_path: './metadata' } }

      it 'keeps the specified screenshots folder' do
        expect(options[:screenshots_path]).to eq('./screenshots')
      end

      it 'keeps the specified metadata folder' do
        expect(options[:metadata_path]).to eq('./metadata')
      end
    end
  end
end
