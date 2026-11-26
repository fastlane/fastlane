require 'deliver/upload_custom_product_page_screenshots'

describe Deliver::UploadCustomProductPageScreenshots do
  let(:app) { double('Spaceship::ConnectAPI::App', id: 'app-1', name: 'Test App') }

  before do
    allow(Deliver).to receive(:cache).and_return({ app: app })
    allow(FastlaneCore::Helper).to receive(:with_loading_indicator).and_yield
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

  def mock_cpp(name: 'My CPP', id: 'cpp-123', app_id: 'app-1')
    owner = app_id ? double('Spaceship::ConnectAPI::App', id: app_id) : nil
    double('Spaceship::ConnectAPI::AppCustomProductPage', name: name, id: id, app: owner)
  end

  def mock_version(id: 'ver-1', version: '1', state: 'PREPARE_FOR_SUBMISSION')
    model = Spaceship::ConnectAPI::AppCustomProductPageVersion.new(id, { 'version' => version, 'state' => state })
    allow(model).to receive(:get_localizations).and_return([])
    allow(model).to receive(:create_localization)
    model
  end

  def mock_localization(locale: 'en-US')
    double('Spaceship::ConnectAPI::AppCustomProductPageLocalization', locale: locale, get_app_screenshot_sets: [])
  end

  def mock_screenshot(language: 'en-US', path: '/path/to/screenshot.png', display_type: 'APP_IPHONE_55')
    double('Deliver::AppScreenshot', language: language, path: path, display_type: display_type)
  end

  def stub_page(cpp, versions)
    allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).with(app_custom_product_page_id: cpp.id, includes: 'app').and_return([cpp])
    allow(Spaceship::ConnectAPI::AppCustomProductPageVersion).to receive(:all).with(app_custom_product_page_id: cpp.id).and_return(versions)
  end

  # A subject whose upload steps are stubbed, so a test only checks which steps run
  def stubbed_subject
    subject = described_class.new
    allow(subject).to receive(:delete_screenshots)
    allow(subject).to receive(:upload_screenshots)
    allow(subject).to receive(:sort_screenshots)
    subject
  end

  describe '#upload' do
    context 'early returns and option errors' do
      it 'returns immediately when skip_screenshots is set' do
        expect(Spaceship::ConnectAPI::AppCustomProductPage).not_to receive(:get)
        described_class.new.upload(mock_options(skip_screenshots: true), [])
      end

      it 'errors when edit_live is set' do
        expect(Spaceship::ConnectAPI::AppCustomProductPage).not_to receive(:get)
        expect { described_class.new.upload(mock_options(edit_live: true), []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /edit_live/)
      end

      it 'errors when custom_product_page_id is nil' do
        expect { described_class.new.upload(mock_options(custom_product_page_id: nil), []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /custom_product_page_id/)
      end

      it 'errors when custom_product_page_id is an empty string' do
        expect { described_class.new.upload(mock_options(custom_product_page_id: '  '), []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /custom_product_page_id/)
      end

      it 'errors in sync mode without the beta feature flag, before any request' do
        allow(FastlaneCore::Feature).to receive(:enabled?).with('FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS').and_return(false)
        expect(Spaceship::ConnectAPI::AppCustomProductPage).not_to receive(:get)
        expect { described_class.new.upload(mock_options(sync_screenshots: true), []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS/)
      end
    end

    context 'custom product page lookup' do
      it 'errors when the page is not found' do
        allow(Spaceship::ConnectAPI::AppCustomProductPage).to receive(:get).and_return([])
        expect { described_class.new.upload(mock_options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not find Custom Product Page/)
      end

      it 'errors when the page belongs to another app' do
        stub_page(mock_cpp(app_id: 'app-2'), [mock_version])
        expect(Spaceship::ConnectAPI::AppCustomProductPageVersion).not_to receive(:all)
        expect { described_class.new.upload(mock_options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /does not belong to app 'Test App'/)
      end

      it 'errors when the page has no app' do
        stub_page(mock_cpp(app_id: nil), [mock_version])
        expect { described_class.new.upload(mock_options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /does not belong to app/)
      end
    end

    context 'version selection' do
      it 'errors when no versions exist' do
        stub_page(mock_cpp, [])
        expect { described_class.new.upload(mock_options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /no versions/)
      end

      it 'errors when no version is editable, listing the states' do
        stub_page(mock_cpp, [mock_version(version: '1', state: 'APPROVED'), mock_version(id: 'ver-2', version: '2', state: 'WAITING_FOR_REVIEW')])
        expect { described_class.new.upload(mock_options, []) }.to raise_error(FastlaneCore::Interface::FastlaneError, /version 1: APPROVED, version 2: WAITING_FOR_REVIEW/)
      end

      it 'selects the editable version with the highest version number, whatever the API order' do
        newest = mock_version(id: 'ver-10', version: '10')
        older = mock_version(id: 'ver-9', version: '9')
        approved = mock_version(id: 'ver-11', version: '11', state: 'APPROVED')
        stub_page(mock_cpp, [newest, approved, older])

        stubbed_subject.upload(mock_options, [])
        expect(newest).to have_received(:get_localizations)
        expect(older).not_to have_received(:get_localizations)
        expect(approved).not_to have_received(:get_localizations)
      end

      it 'treats a rejected version as editable' do
        rejected = mock_version(version: '2', state: 'REJECTED')
        stub_page(mock_cpp, [mock_version(id: 'ver-0', version: '1', state: 'APPROVED'), rejected])

        stubbed_subject.upload(mock_options, [])
        expect(rejected).to have_received(:get_localizations)
      end
    end

    context 'localization activation' do
      let(:version) { mock_version }

      before { stub_page(mock_cpp, [version]) }

      it 'creates missing locales and uploads to the refreshed localizations' do
        en_loc = mock_localization(locale: 'en-US')
        fr_loc = mock_localization(locale: 'fr-FR')
        allow(version).to receive(:get_localizations).and_return([en_loc], [en_loc, fr_loc])
        screenshot = mock_screenshot(language: 'fr-FR')

        subject = stubbed_subject
        subject.upload(mock_options, [screenshot])
        expect(version).to have_received(:create_localization).with(attributes: { locale: 'fr-FR' })
        expect(subject).to have_received(:upload_screenshots).with([en_loc, fr_loc], { 'fr-FR' => [screenshot] }, 3600)
      end

      it 'skips activation when all locales exist' do
        allow(version).to receive(:get_localizations).and_return([mock_localization(locale: 'en-US')])

        stubbed_subject.upload(mock_options, [mock_screenshot(language: 'en-US')])
        expect(version).not_to have_received(:create_localization)
      end
    end

    context 'mode delegation' do
      let(:en_loc) { mock_localization(locale: 'en-US') }
      let(:screenshot) { mock_screenshot(language: 'en-US') }

      before do
        version = mock_version
        allow(version).to receive(:get_localizations).and_return([en_loc])
        stub_page(mock_cpp, [version])
      end

      it 'syncs the page localizations with SyncScreenshots in sync mode' do
        allow(FastlaneCore::Feature).to receive(:enabled?).with('FASTLANE_ENABLE_BETA_DELIVER_SYNC_SCREENSHOTS').and_return(true)
        sync = Deliver::SyncScreenshots.new
        allow(Deliver::SyncScreenshots).to receive(:new).and_return(sync)
        expect(sync).to receive(:sync_localizations).with([en_loc], [screenshot])

        subject = stubbed_subject
        subject.upload(mock_options(sync_screenshots: true), [screenshot])
        expect(subject).not_to have_received(:upload_screenshots)
        expect(subject).not_to have_received(:delete_screenshots)
      end

      it 'deletes then uploads in overwrite mode' do
        subject = stubbed_subject
        subject.upload(mock_options(overwrite_screenshots: true), [screenshot])
        expect(subject).to have_received(:delete_screenshots).with([en_loc], { 'en-US' => [screenshot] }).ordered
        expect(subject).to have_received(:upload_screenshots).ordered
        expect(subject).to have_received(:sort_screenshots).with([en_loc])
      end

      it 'only uploads in default mode' do
        subject = stubbed_subject
        subject.upload(mock_options, [screenshot])
        expect(subject).not_to have_received(:delete_screenshots)
        expect(subject).to have_received(:upload_screenshots)
        expect(subject).to have_received(:sort_screenshots).with([en_loc])
      end
    end
  end
end
