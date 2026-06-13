require 'deliver/upload_custom_product_page_screenshots'

describe Deliver::UploadCustomProductPageScreenshots do
  let(:app) { double('Spaceship::ConnectAPI::App', name: 'Test App') }

  before do
    allow(Deliver).to receive(:cache).and_return({ app: app })
    allow(FastlaneCore::Helper).to receive(:show_loading_indicator)
    allow(FastlaneCore::Helper).to receive(:hide_loading_indicator)
  end

  def mock_options(overrides = {})
    {
      skip_screenshots: false,
      edit_live: false,
      custom_product_page_id: 'cpp-123',
      sync_screenshots: false,
      overwrite_screenshots: false,
      screenshot_processing_timeout: 3600
    }.merge(overrides)
  end

  def mock_cpp(name: 'My CPP', id: 'cpp-123')
    double('Spaceship::ConnectAPI::AppCustomProductPage', name: name, id: id)
  end

  def mock_version(id: 'ver-1', state: 'PREPARE_FOR_SUBMISSION')
    version = double('Spaceship::ConnectAPI::AppCustomProductPageVersion', id: id, state: state)
    allow(version).to receive(:get_localizations).and_return([])
    allow(version).to receive(:create_localization)
    version
  end

  def mock_localization(locale: 'en-US')
    double('Spaceship::ConnectAPI::AppCustomProductPageLocalization', locale: locale, get_app_screenshot_sets: [])
  end

  def mock_screenshot(language: 'en-US', path: '/path/to/screenshot.png', display_type: 'APP_IPHONE_55')
    double('Deliver::AppScreenshot', language: language, path: path, display_type: display_type)
  end

  describe '#upload' do
    context 'early returns' do
      it 'returns immediately when skip_screenshots is set' do
        options = mock_options(skip_screenshots: true)
        expect(Spaceship::ConnectAPI::AppCustomProductPage).not_to receive(:get)
        described_class.new.upload(options, [])
      end

      it 'returns immediately when edit_live is set' do
        options = mock_options(edit_live: true)
        expect(Spaceship::ConnectAPI::AppCustomProductPage).not_to receive(:get)
        described_class.new.upload(options, [])
      end
    end

    context 'error cases' do
      it 'errors when custom_product_page_id is nil' do
        options = mock_options(custom_product_page_id: nil)
        expect { described_class.new.upload(options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /custom_product_page_id/)
      end

      it 'errors when custom_product_page_id is empty string' do
        options = mock_options(custom_product_page_id: '  ')
        expect { described_class.new.upload(options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /custom_product_page_id/)
      end

      it 'errors when CPP not found' do
        options = mock_options
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([])
        expect { described_class.new.upload(options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not find custom product page/)
      end

      it 'errors when no versions exist' do
        options = mock_options
        cpp = mock_cpp
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([cpp])
        allow(Spaceship::ConnectAPI::AppCustomProductPageVersion).to receive(:all).and_return([])
        expect { described_class.new.upload(options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /no versions/)
      end

      it 'errors when no editable version found' do
        options = mock_options
        cpp = mock_cpp
        version = mock_version(id: 'ver-1', state: 'ACCEPTED')
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([cpp])
        allow(Spaceship::ConnectAPI::AppCustomProductPageVersion).to receive(:all).and_return([version])
        expect { described_class.new.upload(options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /No editable version/)
      end

    end

    context 'version selection' do
      it 'auto-selects most recent editable version' do
        options = mock_options
        cpp = mock_cpp
        old_version = mock_version(id: 'ver-old', state: 'ACCEPTED')
        new_version = mock_version(id: 'ver-new', state: 'PREPARE_FOR_SUBMISSION')
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([cpp])
        allow(Spaceship::ConnectAPI::AppCustomProductPageVersion).to receive(:all).and_return([old_version, new_version])
        allow(new_version).to receive(:get_localizations).and_return([])

        subject = described_class.new
        allow(subject).to receive(:upload_screenshots)
        allow(subject).to receive(:sort_screenshots)

        subject.upload(options, [])
        # Should use new_version (last editable version after reverse)
        expect(new_version).to have_received(:get_localizations)
      end
    end

    context 'localization activation' do
      it 'creates missing locales' do
        options = mock_options
        cpp = mock_cpp
        version = mock_version(id: 'ver-1', state: 'DRAFT')
        en_loc = mock_localization(locale: 'en-US')
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([cpp])
        allow(Spaceship::ConnectAPI::AppCustomProductPageVersion).to receive(:all).and_return([version])
        # First call returns only en-US; after creation, returns both
        fr_loc = mock_localization(locale: 'fr-FR')
        allow(version).to receive(:get_localizations).and_return([en_loc], [en_loc, fr_loc])

        screenshot = mock_screenshot(language: 'fr-FR')

        subject = described_class.new
        allow(subject).to receive(:upload_screenshots)
        allow(subject).to receive(:sort_screenshots)

        subject.upload(options, [screenshot])
        expect(version).to have_received(:create_localization).with(attributes: { locale: 'fr-FR' })
      end

      it 'skips activation when all locales exist' do
        options = mock_options
        cpp = mock_cpp
        version = mock_version(id: 'ver-1', state: 'DRAFT')
        en_loc = mock_localization(locale: 'en-US')
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([cpp])
        allow(Spaceship::ConnectAPI::AppCustomProductPageVersion).to receive(:all).and_return([version])
        allow(version).to receive(:get_localizations).and_return([en_loc])

        screenshot = mock_screenshot(language: 'en-US')

        subject = described_class.new
        allow(subject).to receive(:upload_screenshots)
        allow(subject).to receive(:sort_screenshots)

        subject.upload(options, [screenshot])
        expect(version).not_to have_received(:create_localization)
      end
    end

    context 'mode delegation' do
      let(:cpp) { mock_cpp }
      let(:version) { mock_version(id: 'ver-1', state: 'DRAFT') }
      let(:en_loc) { mock_localization(locale: 'en-US') }
      let(:screenshot) { mock_screenshot(language: 'en-US') }

      before do
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([cpp])
        allow(Spaceship::ConnectAPI::AppCustomProductPageVersion).to receive(:all).and_return([version])
        allow(version).to receive(:get_localizations).and_return([en_loc])
      end

      it 'calls sync_replace_screenshots in sync mode' do
        options = mock_options(sync_screenshots: true)

        subject = described_class.new
        allow(subject).to receive(:sync_replace_screenshots)
        allow(subject).to receive(:sort_screenshots)

        subject.upload(options, [screenshot])
        expect(subject).to have_received(:sync_replace_screenshots)
      end

      it 'calls delete_screenshots then upload_screenshots in overwrite mode' do
        options = mock_options(overwrite_screenshots: true)

        subject = described_class.new
        allow(subject).to receive(:delete_screenshots)
        allow(subject).to receive(:upload_screenshots)
        allow(subject).to receive(:sort_screenshots)

        subject.upload(options, [screenshot])
        expect(subject).to have_received(:delete_screenshots)
        expect(subject).to have_received(:upload_screenshots)
      end

      it 'calls upload_screenshots in default mode' do
        options = mock_options

        subject = described_class.new
        allow(subject).to receive(:upload_screenshots)
        allow(subject).to receive(:sort_screenshots)

        subject.upload(options, [screenshot])
        expect(subject).to have_received(:upload_screenshots)
      end
    end
  end

  describe '#sync_replace_screenshots' do
    subject { described_class.new }

    let(:iterator) { double('Deliver::AppScreenshotIterator') }
    let(:screenshots) { [mock_screenshot] }

    before do
      allow(subject).to receive(:create_delete_worker).and_return(double('worker', batch_enqueue: nil, start: nil))
      allow(subject).to receive(:create_upload_worker).and_return(double('worker', batch_enqueue: nil, start: nil))
      allow(subject).to receive(:do_sync_replace_screenshots)
    end

    it 'returns when all complete' do
      allow(subject).to receive(:wait_for_complete_sync).and_return({ processing: false, complete: 1, failing: [] })
      subject.sync_replace_screenshots(iterator, screenshots)
    end

    it 'retries on processing/failures' do
      # First call: still processing; second call: complete
      call_count = 0
      allow(subject).to receive(:wait_for_complete_sync) do
        call_count += 1
        if call_count == 1
          { processing: false, complete: 0, failing: [] }
        else
          { processing: false, complete: 1, failing: [] }
        end
      end

      subject.sync_replace_screenshots(iterator, screenshots, 3)
    end

    it 'crashes when retries exhausted' do
      failing_screenshot = double('app_screenshot', delete!: nil)
      allow(subject).to receive(:wait_for_complete_sync).and_return({ processing: false, complete: 0, failing: [failing_screenshot] })

      expect { subject.sync_replace_screenshots(iterator, screenshots, 0) }.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end
  end

  describe '#wait_for_complete_sync' do
    subject { described_class.new }

    def mock_iterator_with_screenshots(screenshots)
      iterator = double('Deliver::AppScreenshotIterator')
      localization = mock_localization
      app_screenshot_set = double('app_screenshot_set')
      enumerator_data = screenshots.map { |s| [localization, app_screenshot_set, s] }
      allow(iterator).to receive(:each_app_screenshot) do |&block|
        next(enumerator_data) unless block
        enumerator_data.each { |args| block.call(*args) }
      end
      iterator
    end

    it 'returns immediately when nothing is processing' do
      app_screenshot = double('app_screenshot',
                              asset_delivery_state: { 'state' => 'COMPLETE' },
                              error?: false)
      iterator = mock_iterator_with_screenshots([app_screenshot])

      result = subject.wait_for_complete_sync(iterator)
      expect(result[:processing]).to be false
      expect(result[:complete]).to eq(1)
    end

    it 'polls when screenshots are still processing' do
      app_screenshot = double('app_screenshot')
      allow(app_screenshot).to receive(:error?).and_return(false)
      # First poll: UPLOAD_COMPLETE, second poll: COMPLETE
      allow(app_screenshot).to receive(:asset_delivery_state).and_return(
        { 'state' => 'UPLOAD_COMPLETE' },
        { 'state' => 'COMPLETE' }
      )

      iterator = mock_iterator_with_screenshots([app_screenshot])
      allow(subject).to receive(:sleep)

      result = subject.wait_for_complete_sync(iterator)
      expect(result[:processing]).to be false
      expect(result[:complete]).to eq(1)
      expect(subject).to have_received(:sleep).once
    end

    it 'reports failing screenshots' do
      app_screenshot = double('app_screenshot',
                              asset_delivery_state: { 'state' => 'COMPLETE' },
                              error?: true)
      iterator = mock_iterator_with_screenshots([app_screenshot])

      result = subject.wait_for_complete_sync(iterator)
      expect(result[:failing]).to eq([app_screenshot])
    end
  end

  describe '#create_upload_worker' do
    it 'creates a worker that calls upload_screenshot on the job' do
      subject = described_class.new
      worker = subject.create_upload_worker

      app_screenshot_set = double('app_screenshot_set')
      expect(app_screenshot_set).to receive(:upload_screenshot).with(path: '/path/to/img.png', wait_for_processing: false)

      job = Deliver::UploadCustomProductPageScreenshots::CPPUploadScreenshotJob.new(app_screenshot_set, '/path/to/img.png')
      worker.instance_variable_get(:@block).call(job)
    end
  end

  describe '#create_delete_worker' do
    it 'creates a worker that calls delete! on the job screenshot' do
      subject = described_class.new
      worker = subject.create_delete_worker

      app_screenshot = double('app_screenshot', id: 'ss-1', file_name: 'test.png')
      expect(app_screenshot).to receive(:delete!)

      job = Deliver::UploadCustomProductPageScreenshots::CPPDeleteScreenshotJob.new(app_screenshot, 'en-US')
      worker.instance_variable_get(:@block).call(job)
    end
  end
end
