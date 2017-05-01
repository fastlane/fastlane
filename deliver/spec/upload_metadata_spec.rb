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
end
