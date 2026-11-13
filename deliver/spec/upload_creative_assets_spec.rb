require 'tmpdir'
require 'deliver/runner'

describe Deliver::UploadCreativeAssets do
  let(:uploader) { described_class.new }
  let(:entry) { { locale: 'en-US', path: @path, placement_type: 'PRODUCT_PAGE_HEADER_ASSET', placement_group: 'header-group' } }
  let(:options) { { creative_assets: [entry], platform: 'ios' } }
  let(:localization) { double('localization', id: 'localization-id', locale: 'en-US') }
  let(:version) { double('version', app_version_state: 'PREPARE_FOR_SUBMISSION', get_app_store_version_localizations: [localization]) }
  let(:app) { double('app', id: 'app-id', get_edit_app_store_version: version) }
  let(:library) { double('library', id: 'library-id') }
  let(:image) { double('image', id: 'image-id', spec_id: 'image-spec') }
  let(:placement) { double('placement', placement_type: entry[:placement_type], placement_group: entry[:placement_group]) }
  let(:reference) do
    double('reference',
           features: [{ 'featureId' => 'APP_STORE_VERSIONS', 'placementPolicies' => [
             { 'placementType' => entry[:placement_type], 'groupLimits' => [{ 'groupIds' => ['header-group'], 'maxCount' => 1 }] }
           ] }],
           placement_types: [{ 'placementTypeId' => entry[:placement_type], 'acceptsAssetCategories' => ['CREATIVE_ASSETS'],
                               'specMappings' => [{ 'placementGroupId' => 'header-group', 'specs' => ['image-spec'] }] }])
  end

  around do |example|
    Dir.mktmpdir do |dir|
      @path = File.join(dir, 'header.png')
      File.binwrite(@path, 'image bytes')
      example.run
    end
  end

  before do
    Deliver.cache[:app] = app
  end

  describe '.validate' do
    it 'accepts symbol and string keys' do
      expect { described_class.validate([entry]) }.not_to raise_error
      expect { described_class.validate([entry.transform_keys(&:to_s)]) }.not_to raise_error
    end

    it 'rejects a missing file' do
      entry[:path] += '.missing'
      expect { described_class.validate([entry]) }.to raise_error(/Could not find creative asset/)
    end

    it 'rejects unsupported file formats and placements' do
      entry[:placement_type] = 'SEARCH_RESULTS_ADS_ASSET'
      expect { described_class.validate([entry]) }.to raise_error(/placement_type/)
      entry[:placement_type] = 'PRODUCT_PAGE_HEADER_ASSET'
      entry[:path] = __FILE__
      expect { described_class.validate([entry]) }.to raise_error(/PNG or JPEG/)
    end

    it 'rejects missing fields, unknown fields, non-hashes and duplicate targets' do
      expect { described_class.validate([entry.merge(locale: '')]) }.to raise_error(/locale/)
      expect { described_class.validate([entry.merge(typo: 'value')]) }.to raise_error(/Unknown/)
      expect { described_class.validate(['file.png']) }.to raise_error(/Hash/)
      expect { described_class.validate([entry, entry]) }.to raise_error(/Duplicate/)
    end
  end

  describe 'options' do
    it 'validates creative assets through ConfigItem and defaults overwrite to false' do
      config = FastlaneCore::Configuration.create(Deliver::Options.available_options, creative_assets: [entry])
      expect(config[:overwrite_creative_assets]).to eq(false)
      expect(config[:creative_assets]).to eq([entry])
      expect do
        FastlaneCore::Configuration.create(Deliver::Options.available_options, creative_assets: [entry.merge(locale: '')])
      end.to raise_error(/locale/)
    end
  end

  describe '#upload' do
    before do
      allow(Spaceship::ConnectAPI::AppAssetLibrary).to receive(:get).with(app_id: app.id).and_return(library)
      allow(Spaceship::ConnectAPI::AppAssetLibraryRefDatum).to receive(:all).and_return([reference])
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id).and_return([])
      allow(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).and_return(image)
    end

    describe 'videos' do
      let(:video_entry) { entry.merge(path: @video_path, preview_frame_time_code: '00:00:01:00') }
      let(:video) { double('video', id: 'video-id', spec_id: 'video-spec') }

      before do
        @video_path = File.join(File.dirname(@path), 'header.mp4')
        File.binwrite(@video_path, 'video bytes')
        options[:creative_assets] = [video_entry]
        reference.placement_types.first['specMappings'].first['specs'] << 'video-spec'
        allow(reference).to receive(:video_specs).and_return([{ 'specId' => 'video-spec' }])
      end

      it 'accepts supported video extensions and optional frame time codes' do
        ['.mp4', '.mov', '.m4v', '.MP4'].each do |extension|
          path = @video_path + extension
          File.binwrite(path, 'video bytes')
          expect { described_class.validate([video_entry.merge(path: path)]) }.not_to raise_error
        end
        expect { described_class.validate([video_entry.except(:preview_frame_time_code)]) }.not_to raise_error
      end

      it 'rejects empty or non-string time codes and a time code supplied for an image' do
        ['', ' ', 12, nil].each do |time_code|
          expect { described_class.validate([video_entry.merge(preview_frame_time_code: time_code)]) }.to raise_error(/preview_frame_time_code/)
        end
        expect { described_class.validate([entry.merge(preview_frame_time_code: '00:00:01:00')]) }.to raise_error(/only.*video/)
      end

      it 'uploads a video and places it through the video relationship' do
        expect(Spaceship::ConnectAPI::AppAssetLibraryImage).not_to receive(:create)
        expect(Spaceship::ConnectAPI::AppAssetLibraryVideo).to receive(:create).with(app_asset_library_id: library.id, path: @video_path, category: 'CREATIVE_ASSETS', preview_frame_time_code: '00:00:01:00').and_return(video)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(app_store_version_localization_id: localization.id, video_id: video.id, placement_type: entry[:placement_type], placement_group: entry[:placement_group])
        uploader.upload(options)
      end

      it 'replaces only the requested target after video and preview processing succeed' do
        options[:overwrite_creative_assets] = true
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([placement])
        expect(Spaceship::ConnectAPI::AppAssetLibraryVideo).to receive(:create).ordered.and_return(video)
        expect(placement).to receive(:delete!).ordered
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).ordered.with(hash_including(video_id: video.id))
        uploader.upload(options)
      end

      it 'supports images and videos in the same run' do
        japanese = double('localization', id: 'ja-id', locale: 'ja')
        allow(version).to receive(:get_app_store_version_localizations).and_return([localization, japanese])
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([])
        options[:creative_assets] = [entry, video_entry.merge(locale: 'ja')]
        expect(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).once.and_return(image)
        expect(Spaceship::ConnectAPI::AppAssetLibraryVideo).to receive(:create).once.and_return(video)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(hash_including(image_id: image.id))
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(hash_including(video_id: video.id))
        uploader.upload(options)
      end

      it 'reuses a video with the same frame but keeps different frame choices separate' do
        japanese = double('localization', id: 'ja-id', locale: 'ja')
        german = double('localization', id: 'de-id', locale: 'de-DE')
        allow(version).to receive(:get_app_store_version_localizations).and_return([localization, japanese, german])
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([])
        options[:creative_assets] += [video_entry.merge(locale: 'ja'), video_entry.merge(locale: 'de-DE', preview_frame_time_code: '00:00:02:00')]
        expect(Spaceship::ConnectAPI::AppAssetLibraryVideo).to receive(:create).with(hash_including(preview_frame_time_code: '00:00:01:00')).once.and_return(video)
        expect(Spaceship::ConnectAPI::AppAssetLibraryVideo).to receive(:create).with(hash_including(preview_frame_time_code: '00:00:02:00')).once.and_return(video)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).exactly(3).times
        uploader.upload(options)
      end

      it 'rejects a target without a compatible video spec before reserving anything' do
        allow(reference).to receive(:video_specs).and_return([{ 'specId' => 'other-spec' }])
        expect(Spaceship::ConnectAPI::AppAssetLibraryVideo).not_to receive(:create)
        expect { uploader.upload(options) }.to raise_error(/video specification/)
      end

      it 'preserves existing placement if video or preview-frame processing fails' do
        options[:overwrite_creative_assets] = true
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([placement])
        allow(Spaceship::ConnectAPI::AppAssetLibraryVideo).to receive(:create).and_raise('preview processing failed')
        expect(placement).not_to receive(:delete!)
        expect { uploader.upload(options) }.to raise_error('preview processing failed')
      end

      it 'preserves existing placement if the processed video has the wrong spec' do
        options[:overwrite_creative_assets] = true
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([placement])
        allow(Spaceship::ConnectAPI::AppAssetLibraryVideo).to receive(:create).and_return(video)
        allow(video).to receive(:spec_id).and_return('wrong-spec')
        expect(placement).not_to receive(:delete!)
        expect { uploader.upload(options) }.to raise_error(/not compatible/)
      end
    end

    it 'does nothing when no creative assets were specified' do
      expect(app).not_to receive(:get_edit_app_store_version)
      uploader.upload({})
    end

    it 'uploads and places a creative image even when screenshots are skipped' do
      options[:skip_screenshots] = true
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).with(app_asset_library_id: library.id, path: @path, category: 'CREATIVE_ASSETS').and_return(image)
      expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(app_store_version_localization_id: localization.id, image_id: image.id, placement_type: entry[:placement_type], placement_group: entry[:placement_group])
      uploader.upload(options)
    end

    it 'accepts the organic search results placement type' do
      entry[:placement_type] = 'APP_STORE_SEARCH_RESULTS_ASSET'
      reference.features.first['placementPolicies'].first['placementType'] = entry[:placement_type]
      reference.placement_types.first['placementTypeId'] = entry[:placement_type]
      expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(hash_including(placement_type: 'APP_STORE_SEARCH_RESULTS_ASSET'))
      uploader.upload(options)
    end

    it 'uploads the same image once when reused across localizations' do
      japanese = double('localization', id: 'ja-id', locale: 'ja')
      allow(version).to receive(:get_app_store_version_localizations).and_return([localization, japanese])
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: 'ja-id').and_return([])
      options[:creative_assets] << entry.merge(locale: 'ja')
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).once.and_return(image)
      expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).twice
      uploader.upload(options)
    end

    it 'requires explicit overwrite before uploading anything' do
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([placement])
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).not_to receive(:create)
      expect { uploader.upload(options) }.to raise_error(/overwrite_creative_assets/)
    end

    it 'only replaces the requested placement after successful processing' do
      options[:overwrite_creative_assets] = true
      other = double('other placement', placement_type: 'APP_SCREENSHOT', placement_group: 'header-group')
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([placement, other])
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).ordered.and_return(image)
      expect(placement).to receive(:delete!).ordered
      expect(other).not_to receive(:delete!)
      expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).ordered
      uploader.upload(options)
    end

    it 'preserves placements if uploading fails' do
      options[:overwrite_creative_assets] = true
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([placement])
      allow(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).and_raise('processing failed')
      expect(placement).not_to receive(:delete!)
      expect { uploader.upload(options) }.to raise_error('processing failed')
    end

    it 'preserves placements if Apple matches an incompatible image specification' do
      options[:overwrite_creative_assets] = true
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).and_return([placement])
      allow(image).to receive(:spec_id).and_return('wrong-spec')
      expect(placement).not_to receive(:delete!)
      expect { uploader.upload(options) }.to raise_error(/not compatible/)
    end

    it 'validates every target before uploading, including locales and current catalog groups' do
      options[:creative_assets] << entry.merge(locale: 'ja')
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).not_to receive(:create)
      expect { uploader.upload(options) }.to raise_error(/localization.*ja/)
      options[:creative_assets] = [entry.merge(placement_group: 'unknown')]
      expect { uploader.upload(options) }.to raise_error(/not supported/)
    end

    it 'rejects live version options before accessing Apple' do
      expect(app).not_to receive(:get_edit_app_store_version)
      [:edit_live, :use_live_version].each do |key|
        expect { uploader.upload(options.merge(key => true)) }.to raise_error(/editable version/)
      end
    end

    it 'reports a missing editable version or reference catalog' do
      allow(app).to receive(:get_edit_app_store_version).and_return(nil)
      expect { uploader.upload(options) }.to raise_error(/version to edit/)
      allow(app).to receive(:get_edit_app_store_version).and_return(version)
      allow(Spaceship::ConnectAPI::AppAssetLibraryRefDatum).to receive(:all).and_return([])
      expect { uploader.upload(options) }.to raise_error(/reference data/)
    end

    it 'rejects review and unknown version states before reserving assets or changing placements' do
      expect(version).not_to receive(:get_app_store_version_localizations)
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).not_to receive(:create)
      expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).not_to receive(:create)
      ['WAITING_FOR_REVIEW', 'IN_REVIEW', 'READY_FOR_DISTRIBUTION', nil].each do |state|
        allow(version).to receive(:app_version_state).and_return(state)
        expect { uploader.upload(options) }.to raise_error(/Creative asset placements cannot be edited/)
      end
    end

    it 'allows editing versions returned to the developer after rejection' do
      ['DEVELOPER_REJECTED', 'REJECTED', 'METADATA_REJECTED', 'INVALID_BINARY'].each do |state|
        allow(version).to receive(:app_version_state).and_return(state)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create)
        uploader.upload(options)
      end
    end
  end
end
