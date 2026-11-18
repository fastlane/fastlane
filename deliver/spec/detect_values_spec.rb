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
        end

        # A directory of its own, not the shared `tmpdir`: the outer `after`
        # removes that one and runs inside this block, so we would be deleting
        # the current directory, which Windows refuses.
        around do |example|
          Dir.mktmpdir { |dir| Dir.chdir(dir) { example.run } }
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

  describe :find_platform do
    # A directory of its own, not the shared `tmpdir`, for the same reason as
    # in 'running without fastlane' above.
    around do |example|
      Dir.mktmpdir { |dir| Dir.chdir(dir) { example.run } }
    end

    def build_options(values)
      FastlaneCore::Configuration.create(Deliver::Options.available_options, values)
    end

    describe 'when a pkg is in the current directory' do
      before do
        FileUtils.touch('MyApp.pkg')
      end

      it 'infers osx when no platform is given' do
        options = build_options({})
        value_detector.find_platform(options)
        expect(options[:platform]).to eq('osx')
      end

      it 'keeps an explicitly passed platform' do
        options = build_options({ platform: 'ios' })
        value_detector.find_platform(options)
        expect(options[:platform]).to eq('ios')
      end

      it 'keeps a platform set via environment variable' do
        FastlaneSpec::Env.with_env_values('DELIVER_PLATFORM' => 'ios') do
          options = build_options({})
          value_detector.find_platform(options)
          expect(options[:platform]).to eq('ios')
        end
      end

      it 'keeps a platform set in the Deliverfile' do
        File.write('Deliverfile', "platform('ios')\n")
        options = build_options({})
        options.load_configuration_file('Deliverfile', nil, true)
        value_detector.find_platform(options)
        expect(options[:platform]).to eq('ios')
      end
    end

    describe 'when an ipa is in the current directory' do
      before do
        FileUtils.touch('MyApp.ipa')
      end

      it 'uses ios when no platform is given' do
        options = build_options({})
        value_detector.find_platform(options)
        expect(options[:platform]).to eq('ios')
      end
    end
  end
end
