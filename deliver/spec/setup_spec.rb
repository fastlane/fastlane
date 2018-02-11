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
          stub_const('Deliver::UploadMetadata::TRADE_REPRESENTATIVE_CONTACT_INFORMATION_VALUES', {})
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
      context 'with trade_representative_contact_information' do
        let(:version) do
          double('version',
                 trade_representative_trade_name: 'John Smith',
                 trade_representative_first_name: 'John',
                 trade_representative_last_name: 'Smith',
                 trade_representative_address_line_1: '1 Infinite Loop',
                 trade_representative_address_line_2: '',
                 trade_representative_address_line_3: '',
                 trade_representative_city_name: 'Cupertino',
                 trade_representative_state: 'California',
                 trade_representative_country: 'United States',
                 trade_representative_postal_code: '95014',
                 trade_representative_phone_number: '+819012345678',
                 trade_representative_email: 'deliver@example.com',
                 trade_representative_is_displayed_on_app_store: 'false')
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
          stub_const('Deliver::UploadMetadata::REVIEW_INFORMATION_VALUES', {})
        end

        it 'generates trade representative contact information' do
          setup.generate_metadata_files(version, tempdir)
          base_dir = File.join(tempdir, 'trade_representative_contact_information')
          %w(trade_name first_name last_name address_line1 city_name state country postal_code phone_number email_address is_displayed_on_app_store).each do |filename|
            expect(File.exist?(File.join(base_dir, "#{filename}.txt"))).to be_truthy
          end
        end
      end
    end
  end
end
