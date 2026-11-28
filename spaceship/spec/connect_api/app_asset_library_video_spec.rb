describe 'App Asset Library videos' do
  let(:video_class) { Spaceship::ConnectAPI::AppAssetLibraryVideo }
  let(:client) { double('Connect API client') }
  let(:path) { File.join('unused', 'header.mov') }
  let(:reservation) { video_class.new('video', { state: 'AWAITING_UPLOAD', upload_operations: [{ 'url' => 'upload' }] }) }
  let(:processing) { video_class.new('video', { state: 'UPLOAD_COMPLETE' }) }
  let(:complete) { video_class.new('video', { state: 'PREPARE_FOR_SUBMISSION', spec_id: 'video-spec', preview_frame_image: { 'state' => 'COMPLETE' } }) }

  before do
    allow(File).to receive(:binread).with(path).and_return('bytes')
    allow(client).to receive(:post_app_asset_library_video).and_return([reservation])
    allow(client).to receive(:patch_app_asset_library_video).and_return([processing])
    allow(Spaceship::ConnectAPI::FileUploader).to receive(:upload)
    allow(video_class).to receive(:sleep)
  end

  it 'uploads a video, commits without checksum and polls with the supplied client' do
    expect(client).to receive(:post_app_asset_library_video).with(app_asset_library_id: 'library', attributes: { fileName: 'header.mov', fileSize: 5, category: 'CREATIVE_ASSETS', referenceName: 'Header' }).and_return([reservation])
    expect(Spaceship::ConnectAPI::FileUploader).to receive(:upload).with(reservation.upload_operations, 'bytes')
    expect(client).to receive(:patch_app_asset_library_video).with(app_asset_library_video_id: 'video', attributes: { uploaded: true }).and_return([processing])
    expect(client).to receive(:get_app_asset_library_video).with(app_asset_library_video_id: 'video').and_return([complete])
    expect(video_class.create(client: client, app_asset_library_id: 'library', path: path, reference_name: 'Header')).to eq(complete)
  end

  it 'waits for a requested preview frame even after video processing completes' do
    frame_processing = video_class.new('video', { state: 'PREPARE_FOR_SUBMISSION', preview_frame_image: { 'state' => 'PROCESSING' } })
    frame_complete = video_class.new('video', { state: 'PREPARE_FOR_SUBMISSION', preview_frame_image: { 'state' => 'COMPLETE' } })
    expect(client).to receive(:post_app_asset_library_video).with(app_asset_library_id: 'library', attributes: { fileName: 'header.mov', fileSize: 5, category: 'CREATIVE_ASSETS', previewFrameTimeCode: '00:00:03:00' }).and_return([reservation])
    expect(client).to receive(:get_app_asset_library_video).twice.and_return([frame_processing], [frame_complete])
    expect(video_class.create(client: client, app_asset_library_id: 'library', path: path, preview_frame_time_code: '00:00:03:00')).to eq(frame_complete)
  end

  it 'keeps waiting while a requested preview frame is absent' do
    without_frame = video_class.new('video', { state: 'PREPARE_FOR_SUBMISSION' })
    allow(client).to receive(:patch_app_asset_library_video).and_return([without_frame])
    allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(0, 601)
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path, preview_frame_time_code: '00:00:03:00') }.to raise_error(/Timed out.*video/)
  end

  it 'waits for the default preview frame when no time code is supplied' do
    frame_processing = video_class.new('video', { state: 'PREPARE_FOR_SUBMISSION', preview_frame_image: { 'state' => 'PROCESSING' } })
    allow(client).to receive(:patch_app_asset_library_video).and_return([frame_processing])
    expect(client).to receive(:get_app_asset_library_video).and_return([complete])
    expect(video_class.create(client: client, app_asset_library_id: 'library', path: path)).to eq(complete)
  end

  it 'reports preview frame failure including the video id and Apple errors' do
    failed_frame = video_class.new('video', { state: 'PREPARE_FOR_SUBMISSION', preview_frame_image: { 'state' => 'FAILED', 'errors' => ['Frame outside duration'] } })
    allow(client).to receive(:patch_app_asset_library_video).and_return([failed_frame])
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path, preview_frame_time_code: '00:00:03:00') }.to raise_error(/video.*Frame outside duration/)
  end

  it 'fails if the default preview frame cannot be generated' do
    failed_frame = video_class.new('video', { state: 'PREPARE_FOR_SUBMISSION', preview_frame_image: { 'state' => 'FAILED', 'errors' => ['Frame extraction failed'] } })
    allow(client).to receive(:patch_app_asset_library_video).and_return([failed_frame])
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error(/video.*Frame extraction failed/)
  end

  it 'reports video processing failure with Apple state details' do
    failure = video_class.new('video', { state: 'FAILED', state_details: { 'errors' => ['Missing audio'] } })
    allow(client).to receive(:patch_app_asset_library_video).and_return([failure])
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error(/video.*Missing audio/)
  end

  it 'bounds processing wait and includes the video id for recovery' do
    allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(0, 601)
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error(/Timed out.*video/)
  end

  it 'caps the final sleep to the remaining timeout' do
    allow(Process).to receive(:clock_gettime).with(Process::CLOCK_MONOTONIC).and_return(0, 599, 600)
    expect(video_class).to receive(:sleep).with(1)
    allow(client).to receive(:get_app_asset_library_video).and_return([processing])
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error(/Timed out.*video/)
  end

  it 'returns the committed resource without polling when requested' do
    expect(client).not_to receive(:get_app_asset_library_video)
    expect(video_class.create(client: client, app_asset_library_id: 'library', path: path, wait_for_processing: false)).to eq(processing)
  end

  it 'rejects nonpositive wait settings before reservation' do
    expect(client).not_to receive(:post_app_asset_library_video)
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path, processing_timeout: 0) }.to raise_error(ArgumentError)
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path, poll_interval: 0) }.to raise_error(ArgumentError)
  end

  it 'does not commit after a failed upload' do
    allow(Spaceship::ConnectAPI::FileUploader).to receive(:upload).and_raise('upload failed')
    expect(client).not_to receive(:patch_app_asset_library_video)
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error('upload failed')
  end

  it 'does not retry a reservation with an ambiguous server failure' do
    expect(client).to receive(:post_app_asset_library_video).once.and_raise('503 Service Unavailable')
    expect { video_class.create(client: client, app_asset_library_id: 'library', path: path) }.to raise_error('503 Service Unavailable')
  end

  it 'parses included videos on placements and their preview attributes' do
    placement = Spaceship::ConnectAPI::Models.parse({
      'data' => { 'type' => 'appAssetLibraryPlacements', 'id' => 'placement', 'relationships' => { 'video' => { 'data' => { 'type' => 'appAssetLibraryVideos', 'id' => 'video' } } } },
      'included' => [{ 'type' => 'appAssetLibraryVideos', 'id' => 'video', 'attributes' => { 'state' => 'PREPARE_FOR_SUBMISSION', 'specId' => 'video-spec', 'videoAsset' => 'https://example.test/video.mov', 'previewFrameTimeCode' => '00:00:03:00', 'previewFrameImage' => { 'state' => 'COMPLETE' } } }]
    })
    expect(placement.video.spec_id).to eq('video-spec')
    expect(placement.video.preview_frame_time_code).to eq('00:00:03:00')
    expect(placement.video.preview_frame_image).to eq({ 'state' => 'COMPLETE' })
    expect(placement.video.video_asset).to eq('https://example.test/video.mov')
  end
end

describe Spaceship::ConnectAPI::AppAssetLibraryPlacement do
  let(:client) { double('Connect API client') }

  it 'creates a video placement without sending an image keyword to the client' do
    expect(client).to receive(:post_app_asset_library_placement).with(app_store_version_localization_id: 'locale', video_id: 'video', attributes: { placementType: 'PRODUCT_PAGE_HEADER_ASSET', placementGroup: 'group' }).and_return(['placement'])
    expect(described_class.create(client: client, app_store_version_localization_id: 'locale', video_id: 'video', placement_type: 'PRODUCT_PAGE_HEADER_ASSET', placement_group: 'group')).to eq('placement')
  end

  it 'requires exactly one media id before calling the client' do
    expect(client).not_to receive(:post_app_asset_library_placement)
    [{}, { image_id: 'image', video_id: 'video' }].each do |media|
      expect { described_class.create(client: client, app_store_version_localization_id: 'locale', placement_type: 'PRODUCT_PAGE_HEADER_ASSET', placement_group: 'group', **media) }.to raise_error(ArgumentError, /exactly one/)
    end
  end
end

describe Spaceship::ConnectAPI::Tunes::API do
  let(:transport) { double('request client') }
  let(:api) { Object.new.extend(described_class).tap { |instance| instance.tunes_request_client = transport } }

  it 'reserves a video with a single transport attempt' do
    attributes = { category: 'CREATIVE_ASSETS', fileName: 'header.mov', fileSize: 5, previewFrameTimeCode: '00:00:03:00' }
    expect(transport).to receive(:post).with('v1/appAssetLibraryVideos', { data: { type: 'appAssetLibraryVideos', attributes: attributes, relationships: { assetLibrary: { data: { type: 'appAssetLibraries', id: 'library' } } } } }, tries: 1)
    api.post_app_asset_library_video(app_asset_library_id: 'library', attributes: attributes)
  end

  it 'commits a video with the uploaded flag alone' do
    expect(transport).to receive(:patch).with('v1/appAssetLibraryVideos/video', { data: { type: 'appAssetLibraryVideos', id: 'video', attributes: { uploaded: true } } })
    api.patch_app_asset_library_video(app_asset_library_video_id: 'video', attributes: { uploaded: true })
  end

  it 'reads video processing state' do
    expect(transport).to receive(:get).with('v1/appAssetLibraryVideos/video', {})
    api.get_app_asset_library_video(app_asset_library_video_id: 'video')
  end

  it 'creates a placement with only the video relationship and a single transport attempt' do
    expect(transport).to receive(:post).with('v1/appAssetLibraryPlacements', {
      data: { type: 'appAssetLibraryPlacements', attributes: {}, relationships: {
        appStoreVersionLocalization: { data: { type: 'appStoreVersionLocalizations', id: 'locale' } },
        video: { data: { type: 'appAssetLibraryVideos', id: 'video' } }
      } }
    }, tries: 1)
    api.post_app_asset_library_placement(app_store_version_localization_id: 'locale', video_id: 'video')
  end

  it 'rejects missing or conflicting media relationships before making a request' do
    expect(transport).not_to receive(:post)
    [{}, { image_id: 'image', video_id: 'video' }].each do |media|
      expect { api.post_app_asset_library_placement(app_store_version_localization_id: 'locale', **media) }.to raise_error(ArgumentError, /exactly one/)
    end
  end
end
