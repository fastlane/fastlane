require 'deliver/upload_metadata'
require 'tempfile'

describe Deliver::UploadMetadata do
  let(:uploader) { Deliver::UploadMetadata.new }
  let(:tmpdir) { Dir.mktmpdir }

  describe '#load_from_filesystem' do
    context 'with review information' do
      let(:options) { { metadata_path: tmpdir, app_review_information: app_review_information } }

      def create_metadata(path, text)
        File.open(File.join(path), 'w') do |f|
          f.write(text)
        end
      end

      before do
        base_dir = FileUtils.mkdir_p(File.join(tmpdir, 'review_information'))
        {
          first_name: 'Alice',
          last_name: 'Smith',
          phone_number: '+819012345678',
          email_address: 'deliver@example.com',
          demo_user: 'user',
          demo_password: 'password',
          notes: 'This is a note from file'
        }.each do |prefix, text|
          create_metadata(File.join(base_dir, "#{prefix}.txt"), text)
        end
      end

      context 'without app_review_information' do
        let(:app_review_information) { nil }
        it 'can load review information from file' do
          uploader.load_from_filesystem(options)
          expect(options[:app_review_information][:first_name]).to eql('Alice')
          expect(options[:app_review_information][:last_name]).to eql('Smith')
          expect(options[:app_review_information][:phone_number]).to eql('+819012345678')
          expect(options[:app_review_information][:email_address]).to eql('deliver@example.com')
          expect(options[:app_review_information][:demo_user]).to eql('user')
          expect(options[:app_review_information][:demo_password]).to eql('password')
          expect(options[:app_review_information][:notes]).to eql('This is a note from file')
        end
      end

      context 'with app_review_information' do
        let(:app_review_information) { { notes: 'This is a note from option' } }
        it 'values will be masked by the in options' do
          uploader.load_from_filesystem(options)
          expect(options[:app_review_information][:first_name]).to eql('Alice')
          expect(options[:app_review_information][:last_name]).to eql('Smith')
          expect(options[:app_review_information][:phone_number]).to eql('+819012345678')
          expect(options[:app_review_information][:email_address]).to eql('deliver@example.com')
          expect(options[:app_review_information][:demo_user]).to eql('user')
          expect(options[:app_review_information][:demo_password]).to eql('password')
          expect(options[:app_review_information][:notes]).to eql('This is a note from option')
        end
      end

      after do
        FileUtils.remove_entry_secure(tmpdir)
      end
    end
  end

  describe "#set_review_information" do
    let(:options) { { metadata_path: tmpdir, app_review_information: app_review_information } }
    let(:version) { double("version") }

    before do
      allow(version).to receive(:review_first_name=)
      allow(version).to receive(:review_last_name=)
      allow(version).to receive(:review_phone_number=)
      allow(version).to receive(:review_email=)
      allow(version).to receive(:review_demo_user=)
      allow(version).to receive(:review_demo_password=)
      allow(version).to receive(:review_notes=)
      allow(version).to receive(:review_user_needed=)
      allow(version).to receive(:review_demo_user).and_return(app_review_information[:demo_user])
      allow(version).to receive(:review_demo_password).and_return(app_review_information[:demo_password])
    end

    context "with review_information" do
      let(:app_review_information) do
        { first_name: "Alice",
          last_name: "Smith",
          phone_number: "+819012345678",
          email_address: "deliver@example.com",
          demo_user: "user",
          demo_password: "password",
          notes: "This is a note" }
      end

      it "set review information" do
        uploader.send("set_review_information", version, options)
        expect(version).to have_received(:review_first_name=).with(app_review_information[:first_name])
        expect(version).to have_received(:review_last_name=).with(app_review_information[:last_name])
        expect(version).to have_received(:review_phone_number=).with(app_review_information[:phone_number])
        expect(version).to have_received(:review_email=).with(app_review_information[:email_address])
        expect(version).to have_received(:review_demo_user=).with(app_review_information[:demo_user])
        expect(version).to have_received(:review_demo_password=).with(app_review_information[:demo_password])
        expect(version).to have_received(:review_notes=).with(app_review_information[:notes])
      end
    end

    context "with demo_user and demo_password" do
      context "with string" do
        let(:app_review_information) { { demo_user: "user", demo_password: "password" } }

        it "review_user_needed is true" do
          uploader.send("set_review_information", version, options)
          expect(version).to have_received(:review_user_needed=).with(true)
        end
      end

      context "with empty string" do
        let(:app_review_information) { { demo_user: "", demo_password: "" } }

        it "review_user_needed is false" do
          uploader.send("set_review_information", version, options)
          expect(version).to have_received(:review_user_needed=).with(false)
        end
      end

      context "with newline" do
        let(:app_review_information) { { demo_user: "\n", demo_password: "\n" } }

        it "review_user_needed is false" do
          uploader.send("set_review_information", version, options)
          expect(version).to have_received(:review_user_needed=).with(false)
        end
      end
    end
  end

  context "with auto_release_date" do
    let(:app) { double('app') }
    let(:version) { double('version') }
    let(:details) { double('details') }
    before do
      allow(uploader).to receive(:verify_available_languages!)
      allow(version).to receive(:save!)
      allow(version).to receive(:release_on_approval=)
      allow(version).to receive(:toggle_phased_release)
      allow(version).to receive(:auto_release_date=)
      allow(app).to receive(:edit_version).and_return(version)
      allow(app).to receive(:details).and_return(details)
      allow(details).to receive(:save!)
    end
    context 'with date' do
      it "auto_release_date is called" do
        options = { auto_release_date: 2, app: app }
        uploader.upload(options)
        expect(version).to have_received(:auto_release_date=).with(2)
      end
    end

    context 'without date' do
      it "auto_release_date is not called" do
        options = { app: app }
        uploader.upload(options)
        expect(version).to_not(have_received(:auto_release_date=).with(2))
      end
    end
  end

  context "with phased_release" do
    let(:app) { double('app') }
    let(:version) { double('version') }
    let(:details) { double('details') }
    before do
      allow(uploader).to receive(:verify_available_languages!)
      allow(version).to receive(:save!)
      allow(version).to receive(:release_on_approval=)
      allow(version).to receive(:toggle_phased_release)
      allow(version).to receive(:auto_release_date=)
      allow(app).to receive(:edit_version).and_return(version)
      allow(app).to receive(:details).and_return(details)
      allow(details).to receive(:save!)
    end

    context 'with true' do
      it "toggle_phased_release is called" do
        uploader.upload(phased_release: true, app: app)
        expect(version).to have_received(:toggle_phased_release).with(enabled: true)
      end
    end

    context 'with false' do
      it "toggle_phased_release is called" do
        uploader.upload(phased_release: false, app: app)
        expect(version).to have_received(:toggle_phased_release).with(enabled: false)
      end
    end

    context 'without value' do
      it "toggle_phased_release is not called" do
        uploader.upload(app: app)
        expect(version).not_to(have_received(:toggle_phased_release).with(enabled: false))
      end
    end
  end

  describe "#languages" do
    let(:options) { { metadata_path: tmpdir } }

    def create_metadata(path, text)
      File.open(File.join(path), 'w') do |f|
        f.write(text)
      end
    end

    def create_filesystem_language(name)
      require 'fileutils'
      FileUtils.mkdir_p("#{tmpdir}/#{name}")
    end

    context "detected languages with only file system" do
      it "languages are 'de-DE', 'el', 'en-US'" do
        options[:languages] = []

        create_filesystem_language('en-US')
        create_filesystem_language('de-DE')
        create_filesystem_language('el')

        uploader.load_from_filesystem(options)
        languages = uploader.detect_languages(options)

        expect(languages.sort).to eql(['de-DE', 'el', 'en-US'])
      end
    end

    context "detected languages with only config options" do
      it "languages are 'en-AU', 'en-CA', 'en-GB'" do
        options[:languages] = ['en-AU', 'en-CA', 'en-GB']

        uploader.load_from_filesystem(options)
        languages = uploader.detect_languages(options)

        expect(languages.sort).to eql(['en-AU', 'en-CA', 'en-GB'])
      end
    end

    context "detected languages with only release notes" do
      it "languages are 'default', 'es-MX'" do
        options[:languages] = []

        options[:release_notes] = {
          'default' => 'something',
          'es-MX' => 'something else'
        }

        uploader.load_from_filesystem(options)
        languages = uploader.detect_languages(options)

        expect(languages.sort).to eql(['default', 'es-MX'])
      end
    end

    context "detected languages with both file system and config options and release notes" do
      it "languages are 'de-DE', 'default', 'el', 'en-AU', 'en-CA', 'en-GB', 'en-US', 'es-MX'" do
        options[:languages] = ['en-AU', 'en-CA', 'en-GB']
        options[:release_notes] = {
          'default' => 'something',
          'en-US' => 'something else',
          'es-MX' => 'something else else'
        }

        create_filesystem_language('en-US')
        create_filesystem_language('de-DE')
        create_filesystem_language('el')

        uploader.load_from_filesystem(options)
        languages = uploader.detect_languages(options)

        expect(languages.sort).to eql(['de-DE', 'default', 'el', 'en-AU', 'en-CA', 'en-GB', 'en-US', 'es-MX'])
      end
    end

    context "with localized version values for release notes" do
      it "default value set for unspecified languages" do
        options[:languages] = ['en-AU', 'en-CA', 'en-GB']
        options[:release_notes] = {
          'default' => 'something',
          'en-US' => 'something else',
          'es-MX' => 'something else else'
        }

        create_filesystem_language('en-US')
        create_filesystem_language('de-DE')
        create_filesystem_language('el')

        uploader.load_from_filesystem(options)
        uploader.assign_defaults(options)

        expect(options[:release_notes]["en-US"]).to eql('something else')
        expect(options[:release_notes]["es-MX"]).to eql('something else else')
        expect(options[:release_notes]["en-AU"]).to eql('something')
        expect(options[:release_notes]["en-CA"]).to eql('something')
        expect(options[:release_notes]["en-GB"]).to eql('something')
        expect(options[:release_notes]["de-DE"]).to eql('something')
        expect(options[:release_notes]["el"]).to eql('something')
      end
    end
  end
end
