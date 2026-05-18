require 'deliver/detect_values'
require 'fileutils'
require 'tmpdir'

describe Deliver::DetectValues do
  let(:value_detector) { Deliver::DetectValues.new }
  let(:tmpdir) { Dir.mktmpdir }

  after do
    FileUtils.remove_entry_secure(tmpdir)
  end

  describe :find_folders do
    describe 'when folders are not specified in options' do
      let(:options) { { screenshots_path: nil, metadata_path: nil } }

      describe 'running with fastlane' do
        before do
          allow(FastlaneCore::Helper).to receive(:fastlane_enabled?).and_return(true)
          allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(File.join(tmpdir, 'fastlane'))
        end

        it 'sets up screenshots folder in fastlane folder' do
          value_detector.find_folders(options)
          expect(options[:screenshots_path]).to eq(File.join(tmpdir, 'fastlane', 'screenshots'))
        end

        it 'sets up metadata folder in fastlane folder' do
          value_detector.find_folders(options)
          expect(options[:metadata_path]).to eq(File.join(tmpdir, 'fastlane', 'metadata'))
        end

        it 'does not automatically set up app previews folder in fastlane folder even if it exists' do
          path = File.join(tmpdir, 'fastlane', 'app-previews')
          FileUtils.mkdir_p(path)
          value_detector.find_folders(options)
          expect(options[:app_previews_path]).to be_nil
        end
      end

      describe 'running without fastlane' do
        before do
          allow(FastlaneCore::Helper).to receive(:fastlane_enabled?).and_return(false)
          @old_cwd = Dir.pwd
          Dir.chdir(tmpdir)
        end

        after do
          Dir.chdir(@old_cwd)
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
