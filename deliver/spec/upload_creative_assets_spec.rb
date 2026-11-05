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
  let(:placement) { double('placement', id: 'old-placement-id', placement_type: entry[:placement_type], placement_group: entry[:placement_group], image: nil) }
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

    it 'rejects videos and unsupported placements' do
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

    it 'processes all distinct images before changing any placements' do
      japanese = double('localization', id: 'ja-id', locale: 'ja')
      later_path = File.join(File.dirname(@path), 'later.png')
      File.binwrite(later_path, 'later image bytes')
      options[:creative_assets] << entry.merge(locale: 'ja', path: later_path)
      options[:overwrite_creative_assets] = true
      allow(version).to receive(:get_app_store_version_localizations).and_return([localization, japanese])
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id).and_return([placement])
      allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: japanese.id).and_return([])
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).with(hash_including(path: @path)).ordered.and_return(image)
      expect(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).with(hash_including(path: later_path)).ordered.and_return(image)
      expect(placement).to receive(:delete!).ordered
      expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(hash_including(app_store_version_localization_id: localization.id)).ordered
      expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(hash_including(app_store_version_localization_id: japanese.id)).ordered
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

    context 'with multiple targets' do
      let(:japanese) { double('localization', id: 'ja-id', locale: 'ja') }
      let(:japanese_placement) { double('placement', id: 'ja-old-id', placement_type: entry[:placement_type], placement_group: entry[:placement_group]) }

      before do
        options[:overwrite_creative_assets] = true
        allow(version).to receive(:get_app_store_version_localizations).and_return([localization, japanese])
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id).and_return([placement])
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: japanese.id).and_return([japanese_placement])
        options[:creative_assets] << entry.merge(locale: 'ja', path: File.join(File.dirname(@path), 'later.png'))
        File.binwrite(options[:creative_assets].last[:path], 'invalid image bytes')
        expect(placement).not_to receive(:delete!)
        expect(japanese_placement).not_to receive(:delete!)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).not_to receive(:create)
      end

      it 'preserves every placement if a later image fails processing' do
        allow(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).with(hash_including(path: options[:creative_assets].last[:path])).and_raise('invalid later image')
        expect { uploader.upload(options) }.to raise_error('invalid later image')
      end

      it 'preserves every placement if a later image has an incompatible spec' do
        incompatible = double('image', id: 'later-image-id', spec_id: 'wrong-spec')
        allow(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).with(hash_including(path: options[:creative_assets].last[:path])).and_return(incompatible)
        expect { uploader.upload(options) }.to raise_error(/not compatible/)
      end

      it 'checks every target specification even when reusing an uploaded image' do
        options[:creative_assets].last[:path] = @path
        options[:creative_assets].last[:placement_group] = 'other-group'
        allow(japanese_placement).to receive(:placement_group).and_return('other-group')
        reference.features.first['placementPolicies'].first['groupLimits'].first['groupIds'] << 'other-group'
        reference.placement_types.first['specMappings'] << { 'placementGroupId' => 'other-group', 'specs' => ['other-spec'] }
        expect(Spaceship::ConnectAPI::AppAssetLibraryImage).to receive(:create).once.and_return(image)
        expect { uploader.upload(options) }.to raise_error(/not compatible/)
      end
    end

    context 'when placement mutation fails' do
      let(:failure) { StandardError.new('connection lost') }

      before do
        options[:overwrite_creative_assets] = true
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id).and_return([placement])
      end

      it 'stops after a failed deletion with context and the original cause' do
        expect(placement).to receive(:delete!).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).not_to receive(:create)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_return([placement])
        expect { uploader.upload(options) }.to raise_error do |error|
          expect(error.message).to include('delete', 'en-US', 'PRODUCT_PAGE_HEADER_ASSET', 'header-group', 'old-placement-id', 'image-id', 'connection lost')
          expect(error.cause).to equal(failure)
        end
      end

      it 'does not retry deletion or create when readback shows the old placement disappeared' do
        expect(placement).to receive(:delete!).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).not_to receive(:create)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_return([])
        expect { uploader.upload(options) }.to raise_error(/No further placement mutations, retries, or rollback/)
      end

      it 'reports deletion followed by failed creation without retrying or rolling back' do
        expect(placement).to receive(:delete!).once
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_return([])
        expect { uploader.upload(options) }.to raise_error do |error|
          expect(error.message).to include('create', 'en-US', 'PRODUCT_PAGE_HEADER_ASSET', 'header-group', 'old-placement-id', 'image-id', 'connection lost')
          expect(error.cause).to equal(failure)
        end
      end

      it 'reports an observed placement without treating an ambiguous creation as successful' do
        observed = double('placement', id: 'new-placement-id', placement_type: entry[:placement_type], placement_group: entry[:placement_group], image: image)
        expect(placement).to receive(:delete!).once
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_return([observed])
        expect { uploader.upload(options) }.to raise_error(/new-placement-id.*image-id/)
      end

      it 'identifies completed deletions when a later deletion fails' do
        later = double('placement', id: 'later-old-id', placement_type: entry[:placement_type], placement_group: entry[:placement_group], image: nil)
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id).and_return([placement, later])
        expect(placement).to receive(:delete!).once
        expect(later).to receive(:delete!).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).not_to receive(:create)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_return([later])
        expect { uploader.upload(options) }.to raise_error do |error|
          expect(error.message).to include('Failed deletion ID: later-old-id', 'Completed deletions: old-placement-id')
          expect(error.cause).to equal(failure)
        end
      end

      it 'excludes unrelated targets from the readback report' do
        unrelated = double('placement', id: 'unrelated-id', placement_type: 'APP_SCREENSHOT', placement_group: entry[:placement_group])
        expect(placement).to receive(:delete!).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).not_to receive(:create)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_return([placement, unrelated])
        expect { uploader.upload(options) }.to raise_error do |error|
          expect(error.message).to include('old-placement-id')
          expect(error.message).not_to include('unrelated-id')
        end
      end

      it 'does not mutate later targets after the first target fails' do
        japanese = double('localization', id: 'ja-id', locale: 'ja')
        later = double('placement', id: 'ja-old-id', placement_type: entry[:placement_type], placement_group: entry[:placement_group])
        options[:creative_assets] << entry.merge(locale: 'ja')
        allow(version).to receive(:get_app_store_version_localizations).and_return([localization, japanese])
        allow(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: japanese.id).and_return([later])
        expect(placement).to receive(:delete!).once
        expect(later).not_to receive(:delete!)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).with(hash_including(app_store_version_localization_id: localization.id)).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).not_to receive(:create).with(hash_including(app_store_version_localization_id: japanese.id))
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_return([])
        expect { uploader.upload(options) }.to raise_error(/connection lost/)
      end

      it 'preserves the mutation failure when readback also fails' do
        expect(placement).to receive(:delete!).once
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:create).once.and_raise(failure)
        expect(Spaceship::ConnectAPI::AppAssetLibraryPlacement).to receive(:all).with(app_store_version_localization_id: localization.id, includes: 'image').once.and_raise('readback unavailable')
        expect { uploader.upload(options) }.to raise_error do |error|
          expect(error.message).to include('connection lost', 'readback unavailable', 'uncertain')
          expect(error.cause).to equal(failure)
        end
      end
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
