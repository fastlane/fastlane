require 'deliver/setup'

describe Deliver do
  describe Deliver::Setup do
    it "properly downloads existing metadata" do
      # app = "app"
      # version = "version"
      # allow(Spaceship::Application).to receive(:find).and_return(app)
      # expect(app).to receive(:latest_version).and_return(version)
      # expect(version).to receive(:name).and_return("name")

      # options = {
      #   app_identifier: "tools.fastlane.app",
      #   username: "flapple@krausefx.com",
      # }
      # Deliver::Runner.new(options) # to login
      # Deliver::Setup.new.run(options)
    end

    describe '#generate_metadata_files' do
      context 'with review_information' do
        let(:version) do
          double('version',
                 review_first_name: 'John',
                 review_last_name: 'Smith',
                 review_phone_number: '+819012345678',
                 review_email: 'deliver@example.com',
                 review_demo_user: 'user',
                 review_demo_password: 'password',
                 review_notes: 'This is a note')
        end
        let(:application) { double('application') }
        let(:setup) { Deliver::Setup.new }
        let(:tempdir) { Dir.mktmpdir }
        before do
          allow(version).to receive_message_chain('application.details').and_return(application)
          allow(version).to receive_message_chain('description.languages').and_return([])
          allow(version).to receive_message_chain('large_app_icon.asset_token').and_return(nil)
          allow(version).to receive_message_chain('watch_app_icon.asset_token').and_return(nil)
          stub_const('Deliver::UploadMetadata::NON_LOCALISED_VERSION_VALUES', [])
          stub_const('Deliver::UploadMetadata::NON_LOCALISED_APP_VALUES', [])
        end

        it 'generates review information' do
          setup.generate_metadata_files(version, tempdir)
          base_dir = File.join(tempdir, 'review_information')
          %w(first_name last_name phone_number email_address demo_user demo_password notes).each do |filename|
            expect(File.exist?(File.join(base_dir, "#{filename}.txt"))).to be_truthy
          end
        end

        after do
          FileUtils.remove_entry_secure(tempdir)
        end
      end
    end
  end
end
