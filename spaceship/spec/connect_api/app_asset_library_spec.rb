describe 'App Asset Library' do
  let(:client) { double('Connect API client') }

  it 'reads the library for the app with the supplied client' do
    library = Spaceship::ConnectAPI::AppAssetLibrary.new('library', {})
    expect(client).to receive(:get_app_asset_library).with(app_id: 'app').and_return([library])
    expect(Spaceship::ConnectAPI::AppAssetLibrary.get(client: client, app_id: 'app')).to eq(library)
  end

  it 'reads reference data without hard-coding placement groups' do
    response = double(to_models: ['reference data'])
    expect(client).to receive(:get_app_asset_library_ref_data).with(filter: { features: 'APP_STORE_VERSIONS' }).and_return(response)
    expect(Spaceship::ConnectAPI::AppAssetLibraryRefDatum.all(client: client, filter: { features: 'APP_STORE_VERSIONS' })).to eq(['reference data'])
  end

  it 'decodes Apple response attributes and an included image relationship' do
    response = {
      'data' => {
        'type' => 'appAssetLibraryPlacements', 'id' => 'placement',
        'attributes' => { 'placementType' => 'PRODUCT_PAGE_HEADER_ASSET', 'placementGroup' => 'group', 'state' => 'PARENT_PREPARE_FOR_SUBMISSION' },
        'relationships' => { 'image' => { 'data' => { 'type' => 'appAssetLibraryImages', 'id' => 'image' } } }
      },
      'included' => [{ 'type' => 'appAssetLibraryImages', 'id' => 'image', 'attributes' => { 'specId' => 'spec', 'stateDetails' => {}, 'state' => 'PREPARE_FOR_SUBMISSION' } }]
    }
    placement = Spaceship::ConnectAPI::Models.parse(response)
    expect(placement.placement_type).to eq('PRODUCT_PAGE_HEADER_ASSET')
    expect(placement.image.spec_id).to eq('spec')
    expect(placement.image).to be_complete
  end

  describe 'image upload' do
    let(:image_class) { Spaceship::ConnectAPI::AppAssetLibraryImage }
    let(:path) { '/unused/header.png' }
    let(:reservation) { image_class.new('image', { state: 'AWAITING_UPLOAD', upload_operations: [{ 'url' => 'upload' }] }) }
    let(:processing) { image_class.new('image', { state: 'UPLOAD_COMPLETE' }) }
    let(:complete) { image_class.new('image', { state: 'PREPARE_FOR_SUBMISSION', spec_id: 'spec' }) }

    before do
      allow(File).to receive(:binread).with(path).and_return('bytes')
      allow(client).to receive(:post_app_asset_library_image).and_return([reservation])
      allow(Spaceship::ConnectAPI::FileUploader).to receive(:upload)
      allow(client).to receive(:patch_app_asset_library_image).and_return([processing])
      allow(image_class).to receive(:sleep)
    end

    it 'uploads and commits without a legacy checksum, then polls using the supplied client' do
      expect(client).to receive(:post_app_asset_library_image).with(app_asset_library_id: 'library', attributes: { fileName: 'header.png', fileSize: 5, category: 'CREATIVE_ASSETS', referenceName: 'Header' }).and_return([reservation])
      expect(Spaceship::ConnectAPI::FileUploader).to receive(:upload).with(reservation.upload_operations, 'bytes')
      expect(client).to receive(:patch_app_asset_library_image).with(app_asset_library_image_id: 'image', attributes: { uploaded: true }).and_return([processing])
      expect(client).to receive(:get_app_asset_library_image).with(app_asset_library_image_id: 'image').and_return([complete])
      expect(image_class.create(client: client, app_asset_library_id: 'library', path: path, reference_name: 'Header')).to eq(complete)
    end

    it 'rejects an unbounded processing configuration before reserving an image' do
      expect(client).not_to receive(:post_app_asset_library_image)
      expect { image_class.create(client: client, app_asset_library_id: 'library', path: path, processing_timeout: 0) }.to raise_error(ArgumentError)
      expect { image_class.create(client: client, app_asset_library_id: 'library', path: path, poll_interval: 0) }.to raise_error(ArgumentError)
    end

    it 'does not retry the reservation after an ambiguous server failure' do
      expect(client).to receive(:post_app_asset_library_image).once.and_raise('503 Service Unavailable')
      expect(Spaceship::ConnectAPI::FileUploader).not_to receive(:upload)
      expect { image_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error('503 Service Unavailable')
    end

    it 'returns immediately when processing is not requested' do
      expect(client).not_to receive(:get_app_asset_library_image)
      expect(image_class.create(client: client, app_asset_library_id: 'library', path: path, wait_for_processing: false)).to eq(processing)
    end

    it 'surfaces processing errors with the reserved image id for recovery' do
      failure = image_class.new('image', { state: 'FAILED', state_details: { 'errors' => ['Unsupported dimensions'] } })
      allow(client).to receive(:get_app_asset_library_image).and_return([failure])
      expect { image_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error(/image.*Unsupported dimensions/)
    end

    it 'bounds processing wait and preserves the image id in the timeout' do
      allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(0, 301)
      expect { image_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error(/Timed out.*image/)
    end

    it 'does not commit or poll after an upload failure' do
      allow(Spaceship::ConnectAPI::FileUploader).to receive(:upload).and_raise('upload failed')
      expect(client).not_to receive(:patch_app_asset_library_image)
      expect { image_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error('upload failed')
    end
  end

  describe 'placements' do
    let(:placement_class) { Spaceship::ConnectAPI::AppAssetLibraryPlacement }
    let(:placement) { placement_class.new('placement', { placement_type: 'APP_STORE_SEARCH_RESULTS_ASSET', placement_group: 'group' }) }

    it 'creates a search-results placement with the supplied client' do
      expect(client).to receive(:post_app_asset_library_placement).with(app_store_version_localization_id: 'locale', image_id: 'image', attributes: { placementType: 'APP_STORE_SEARCH_RESULTS_ASSET', placementGroup: 'group' }).and_return([placement])
      expect(placement_class.create(client: client, app_store_version_localization_id: 'locale', image_id: 'image', placement_type: 'APP_STORE_SEARCH_RESULTS_ASSET', placement_group: 'group')).to eq(placement)
    end

    it 'fetches every page of placements before replacement' do
      page = double(to_models: [placement])
      response = double(all_pages: [page, page])
      expect(client).to receive(:get_app_asset_library_placements).with(app_store_version_localization_id: 'locale', filter: {}, includes: nil, limit: nil, sort: nil).and_return(response)
      expect(placement_class.all(client: client, app_store_version_localization_id: 'locale')).to eq([placement, placement])
    end

    it 'deletes a placement without deleting its library image' do
      expect(client).to receive(:delete_app_asset_library_placement).with(app_asset_library_placement_id: 'placement')
      placement.delete!(client: client)
    end
  end
end

describe Spaceship::ConnectAPI::Tunes::API do
  let(:transport) { double('request client') }
  let(:api) do
    Object.new.extend(described_class).tap { |instance| instance.tunes_request_client = transport }
  end

  it 'reserves the image in the app library with the public JSON API contract' do
    attributes = { category: 'CREATIVE_ASSETS', fileName: 'header.png', fileSize: 5 }
    expect(transport).to receive(:post).with('v1/appAssetLibraryImages', {
      data: {
        type: 'appAssetLibraryImages', attributes: attributes,
        relationships: { assetLibrary: { data: { type: 'appAssetLibraries', id: 'library' } } }
      }
    })
    api.post_app_asset_library_image(app_asset_library_id: 'library', attributes: attributes)
  end

  it 'commits an image with only the uploaded flag' do
    expect(transport).to receive(:patch).with('v1/appAssetLibraryImages/image', { data: { type: 'appAssetLibraryImages', id: 'image', attributes: { uploaded: true } } })
    api.patch_app_asset_library_image(app_asset_library_image_id: 'image', attributes: { uploaded: true })
  end

  it 'associates the placement with one image and one target localization' do
    attributes = { placementType: 'PRODUCT_PAGE_HEADER_ASSET', placementGroup: 'group' }
    expect(transport).to receive(:post).with('v1/appAssetLibraryPlacements', {
      data: {
        type: 'appAssetLibraryPlacements', attributes: attributes,
        relationships: {
          image: { data: { type: 'appAssetLibraryImages', id: 'image' } },
          appStoreVersionLocalization: { data: { type: 'appStoreVersionLocalizations', id: 'locale' } }
        }
      }
    })
    api.post_app_asset_library_placement(app_store_version_localization_id: 'locale', image_id: 'image', attributes: attributes)
  end

  it 'reads the app library relationship' do
    expect(transport).to receive(:get).with('v1/apps/app/assetLibrary', {})
    api.get_app_asset_library(app_id: 'app')
  end

  it 'reads image processing state' do
    expect(transport).to receive(:get).with('v1/appAssetLibraryImages/image', {})
    api.get_app_asset_library_image(app_asset_library_image_id: 'image')
  end

  it 'passes placement filters to the localization relationship' do
    filter = { placementType: 'PRODUCT_PAGE_HEADER_ASSET' }
    expect(transport).to receive(:build_params).with(filter: filter, includes: 'image', limit: 200, sort: nil).and_return({ filter: filter, include: 'image', limit: 200 })
    expect(transport).to receive(:get).with('v1/appStoreVersionLocalizations/locale/placements', { filter: filter, include: 'image', limit: 200 })
    api.get_app_asset_library_placements(app_store_version_localization_id: 'locale', filter: filter, includes: 'image', limit: 200)
  end

  it 'requests reference data for the selected feature' do
    filter = { features: 'APP_STORE_VERSIONS' }
    expect(transport).to receive(:build_params).with(filter: filter, includes: nil, limit: nil, sort: nil).and_return({ filter: filter })
    expect(transport).to receive(:get).with('v1/appAssetLibraryRefData', { filter: filter })
    api.get_app_asset_library_ref_data(filter: filter)
  end

  it 'deletes only the placement' do
    expect(transport).to receive(:delete).with('v1/appAssetLibraryPlacements/placement', {})
    api.delete_app_asset_library_placement(app_asset_library_placement_id: 'placement')
  end
end
