require 'deliver/upload_metadata'
require 'tempfile'

describe Deliver::UploadMetadata do
  let(:tmpdir) { Dir.mktmpdir }

  describe '#load_from_filesystem' do
    context 'with review information' do
      let(:options) { { metadata_path: tmpdir, app_review_information: app_review_information } }
      let(:uploader) { Deliver::UploadMetadata.new(options) }

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
          uploader.load_from_filesystem
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
          uploader.load_from_filesystem
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

  describe "#review_information" do
    let(:options) { { metadata_path: tmpdir, app_review_information: app_review_information } }
    let(:version) { double("version") }
    let(:app_store_review_detail) { double("app_store_review_detail") }
    let(:uploader) { Deliver::UploadMetadata.new(options) }

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

      it "skips review information with empty app_review_information" do
        options[:app_review_information] = {}

        expect(FastlaneCore::UI).not_to receive(:message).with("Uploading app review information to App Store Connect")
        uploader.send(:review_information, version)
      end

      it "successfully set review information" do
        expect(version).to receive(:fetch_app_store_review_detail).and_return(app_store_review_detail)
        expect(app_store_review_detail).to receive(:update).with(attributes: {
          "contact_first_name" => app_review_information[:first_name],
          "contact_last_name" => app_review_information[:last_name],
          "contact_phone" => app_review_information[:phone_number],
          "contact_email" => app_review_information[:email_address],
          "demo_account_name" => app_review_information[:demo_user],
          "demo_account_password" => app_review_information[:demo_password],
          "demo_account_required" => true,
          "notes" => app_review_information[:notes]
        })

        expect(FastlaneCore::UI).to receive(:message).with("Uploading app review information to App Store Connect")

        uploader.send(:review_information, version)
      end
    end

    context "with demo_user and demo_password" do
      context "with string" do
        let(:app_review_information) { { demo_user: "user", demo_password: "password" } }

        it "review_user_needed is true" do
          expect(version).to receive(:fetch_app_store_review_detail).and_return(app_store_review_detail)
          expect(app_store_review_detail).to receive(:update).with(attributes: {
            "demo_account_name" => app_review_information[:demo_user],
            "demo_account_password" => app_review_information[:demo_password],
            "demo_account_required" => true
          })

          uploader.send(:review_information, version)
        end
      end

      context "with empty string" do
        let(:app_review_information) { { demo_user: "", demo_password: "" } }

        it "review_user_needed is false" do
          expect(version).to receive(:fetch_app_store_review_detail).and_return(app_store_review_detail)
          expect(app_store_review_detail).to receive(:update).with(attributes: {
            "demo_account_required" => false
          })

          uploader.send(:review_information, version)
        end
      end

      context "with newline" do
        let(:app_review_information) { { demo_user: "\n", demo_password: "\n" } }

        it "review_user_needed is false" do
          expect(version).to receive(:fetch_app_store_review_detail).and_return(app_store_review_detail)
          expect(app_store_review_detail).to receive(:update).with(attributes: {
            "demo_account_required" => false
          })

          uploader.send(:review_information, version)
        end
      end
    end
  end

  context "with metadata" do
    let(:app) { double('app') }
    let(:id) do
      double('id')
    end
    let(:version) do
      double('version',
             version_string: '1.0.0')
    end
    let(:version_localization_en) do
      double('version_localization_en',
             locale: 'en-US')
    end
    let(:app_info) { double('app_info') }
    let(:live_app_info) { nil }
    let(:app_info_localization_en) do
      double('app_info_localization_en',
             locale: 'en-US')
    end
    let(:app_review_detail) do
      double('app_review_detail')
    end
    let(:app_store_versions) do
      double('app_store_versions',
             count: 0)
    end

    let(:options) { { version_check_wait_retry_limit: 5 } }

    let(:uploader) { Deliver::UploadMetadata.new(options) }

    let(:metadata_path) { Dir.mktmpdir }

    context "fetch app edit" do
      context "#fetch_edit_app_store_version" do
        it "no retry" do
          expect(app).to receive(:get_edit_app_store_version).and_return(version)

          edit_version = uploader.fetch_edit_app_store_version(app, 'IOS')
          expect(edit_version).to eq(version)
        end

        it "1 retry" do
          expect(Kernel).to receive(:sleep).once.with(20)
          expect(app).to receive(:get_edit_app_store_version).and_return(nil)
          expect(app).to receive(:get_edit_app_store_version).and_return(version)

          edit_version = uploader.fetch_edit_app_store_version(app, 'IOS')
          expect(edit_version).to eq(version)
        end

        it "5 retry" do
          expect(Kernel).to receive(:sleep).exactly(5).times
          expect(app).to receive(:get_edit_app_store_version).and_return(nil).exactly(5).times

          edit_version = uploader.fetch_edit_app_store_version(app, 'IOS')
          expect(edit_version).to eq(nil)
        end
      end

      context "#fetch_edit_app_info" do
        it "no retry" do
          expect(app).to receive(:fetch_edit_app_info).and_return(app_info)

          edit_app_info = uploader.fetch_edit_app_info(app)
          expect(edit_app_info).to eq(app_info)
        end

        it "1 retry" do
          expect(Kernel).to receive(:sleep).once.with(20)
          expect(app).to receive(:fetch_edit_app_info).and_return(nil)
          expect(app).to receive(:fetch_edit_app_info).and_return(app_info)

          edit_app_info = uploader.fetch_edit_app_info(app)
          expect(edit_app_info).to eq(app_info)
        end

        it "5 retry" do
          expect(Kernel).to receive(:sleep).exactly(5).times
          expect(app).to receive(:fetch_edit_app_info).and_return(nil).exactly(5).times

          edit_app_info = uploader.fetch_edit_app_info(app)
          expect(edit_app_info).to eq(nil)
        end
      end
    end

    context "#upload" do
      let(:options) { {} }

      before do
        allow(Deliver).to receive(:cache).and_return({ app: app })

        allow(uploader).to receive(:review_information)
        allow(uploader).to receive(:review_attachment_file)
        allow(uploader).to receive(:app_rating)

        # Verify available languages
        expect(app).to receive(:id).and_return(id)
        expect(app).to receive(:get_edit_app_store_version).and_return(version)
        expect(uploader).to receive(:fetch_edit_app_info).and_return(app_info)

        # Get versions
        expect(app).to receive(:get_edit_app_store_version).and_return(version)
        expect(version).to receive(:get_app_store_version_localizations).and_return([version_localization_en])

        # Get app infos
        if app_info
          expect(app_info).to receive(:get_app_info_localizations).and_return([app_info_localization_en])
        else
          expect(live_app_info).to receive(:get_app_info_localizations).and_return([app_info_localization_en])
        end
      end

      context "normal metadata" do
        it "saves metadata" do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:name] = { "en-US" => "App name" }
          options[:description] = { "en-US" => "App description" }
          options[:version_check_wait_retry_limit] = 5

          # Get number of versions (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          expect(version).to receive(:update).with(attributes: {})

          # Get app info
          expect(app_info).to receive(:get_app_info_localizations).and_return([app_info_localization_en])

          # Get app info localization English (Used to compare with data to upload)
          expect(app_info_localization_en).to receive(:name).and_return('App Name')

          # Update version localization
          expect(version_localization_en).to receive(:update).with(attributes: {
            "description" => options[:description]["en-US"]
          })

          # Update app info localization
          expect(app_info_localization_en).to receive(:update).with(attributes: {
            "name" => options[:name]["en-US"]
          })

          # Update app info
          expect(app_info).to receive(:update_categories).with(category_id_map: {})

          uploader.upload
        end
      end

      context "with privacy_url" do
        it 'saves privacy_url' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:privacy_url] = { "en-US" => "https://fastlane.tools" }
          options[:apple_tv_privacy_policy] = { "en-US" => "https://fastlane.tools/tv" }
          options[:version_check_wait_retry_limit] = 5

          # Get number of versions (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          expect(version).to receive(:update).with(attributes: {})

          # Validate symbol names used when comparing privacy urls before upload
          expect(app_info_localization_en).to receive(:privacy_policy_url).and_return(options[:privacy_url]["en-US"])
          expect(app_info_localization_en).to receive(:privacy_policy_text).and_return(options[:apple_tv_privacy_policy]["en-US"])

          # Update app info
          expect(app_info).to receive(:update_categories).with(category_id_map: {})

          uploader.upload
        end
      end

      context "with auto_release_date" do
        it 'with date' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:auto_release_date] = 1_595_395_800_000
          options[:version_check_wait_retry_limit] = 5

          # Get number of version (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          expect(version).to receive(:update).with(attributes: {
            "releaseType" => "SCHEDULED",
            "earliestReleaseDate" => "2020-07-22T05:00:00+00:00"
          })

          # Update app info
          expect(app_info).to receive(:update_categories).with(category_id_map: {})

          uploader.upload
        end
      end

      context "with phased_release" do
        it 'with true' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:phased_release] = true
          options[:automatic_release] = false
          options[:version_check_wait_retry_limit] = 5

          # Get number of version (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          # Defaults to release type manual
          expect(version).to receive(:update).with(attributes: {
            "releaseType" => "MANUAL"
          })

          # Get phased release
          expect(version).to receive(:fetch_app_store_version_phased_release).and_return(nil)

          # Create a phased release
          expect(version).to receive(:create_app_store_version_phased_release).with(attributes: {
            phasedReleaseState: Spaceship::ConnectAPI::AppStoreVersionPhasedRelease::PhasedReleaseState::INACTIVE
          })

          # Update app info
          expect(app_info).to receive(:update_categories).with(category_id_map: {})

          uploader.upload
        end

        it 'with false' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:phased_release] = false
          options[:version_check_wait_retry_limit] = 5

          # Get number of version (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          # Defaults to release type manual
          expect(version).to receive(:update).with(attributes: {})

          # Get phased release
          phased_release = double('phased_release')
          expect(version).to receive(:fetch_app_store_version_phased_release).and_return(phased_release)

          # Delete phased release
          expect(phased_release).to receive(:delete!)

          # Update app info
          expect(app_info).to receive(:update_categories).with(category_id_map: {})

          uploader.upload
        end
      end

      context "with reset_ratings" do
        it 'with select reset_ratings' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:reset_ratings] = true
          options[:version_check_wait_retry_limit] = 5

          # Get number of version (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          # Defaults to release type manual
          expect(version).to receive(:update).with(attributes: {})

          # Get reset ratings request
          expect(version).to receive(:fetch_reset_ratings_request).and_return(nil)

          # Create a reset ratings request
          expect(version).to receive(:create_reset_ratings_request)

          # Update app info
          expect(app_info).to receive(:update_categories).with(category_id_map: {})

          uploader.upload
        end

        it 'does not select reset_ratings' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:reset_ratings] = false
          options[:version_check_wait_retry_limit] = 5

          # Get number of version (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          # Defaults to release type manual
          expect(version).to receive(:update).with(attributes: {})

          # Get reset ratings request
          reset_ratings_request = double('reset_ratings_request')
          expect(version).to receive(:fetch_reset_ratings_request).and_return(reset_ratings_request)

          # Delete reset ratings request
          expect(reset_ratings_request).to receive(:delete!)

          # Update app info
          expect(app_info).to receive(:update_categories).with(category_id_map: {})

          uploader.upload
        end
      end

      context "with no editable app info" do
        let(:live_app_info) { double('app_info') }
        let(:app_info) { nil }

        it 'no new app info provided by user' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:version_check_wait_retry_limit] = 5

          # Get live app info
          expect(app).to receive(:fetch_live_app_info).and_return(live_app_info)

          # Get number of versions (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)
          expect(version).to receive(:update).with(attributes: {})

          uploader.upload
        end

        it 'same app info as live version' do
          options[:platform] = "ios"
          options[:metadata_path] = metadata_path
          options[:name] = { "en-US" => "App name" }
          options[:version_check_wait_retry_limit] = 5

          # Get live app info
          expect(app).to receive(:fetch_live_app_info).and_return(live_app_info)

          # Get number of versions (used for if whats_new should be sent)
          expect(Spaceship::ConnectAPI).to receive(:get_app_store_versions).and_return(app_store_versions)

          expect(version).to receive(:update).with(attributes: {})

          # Get app info localization in English (used to compare with data to upload)
          expect(app_info_localization_en).to receive(:name).and_return('App name')

          uploader.upload
        end
      end
    end

    context "fail when not allowed to update" do
      let(:live_app_info) { double('app_info') }
      let(:app_info) { nil }
      let(:options) {
        {
          platform: "ios",
          metadata_path: metadata_path,
          name: { "en-US" => "New app name" },
          version_check_wait_retry_limit: 5,
        }
      }
      it 'different app info than live version' do
        allow(Deliver).to receive(:cache).and_return({ app: app })

        allow(uploader).to receive(:review_information)
        allow(uploader).to receive(:review_attachment_file)
        allow(uploader).to receive(:app_rating)

        # Get app info
        expect(uploader).to receive(:fetch_edit_app_info).and_return(app_info)
        expect(app).to receive(:fetch_live_app_info).and_return(live_app_info)
        expect(live_app_info).to receive(:get_app_info_localizations).and_return([app_info_localization_en])

        # Get versions
        expect(app).to receive(:get_edit_app_store_version).and_return(version)
        expect(version).to receive(:get_app_store_version_localizations).and_return([version_localization_en])

        # Get app info localization in English (used to compare with data to upload)
        expect(app_info_localization_en).to receive(:name).and_return('App name')

        # Fail because app info can't be updated
        expect(FastlaneCore::UI).to receive(:user_error!).with("Cannot update languages - could not find an editable 'App Info'. Verify that your app is in one of the editable states in App Store Connect").and_call_original

        # Get app info localization in English (used to compare with data to upload)
        expect { uploader.upload }.to raise_error(FastlaneCore::Interface::FastlaneError)
      end
    end
  end

  describe "#languages" do
    let(:options) { { metadata_path: tmpdir } }
    let(:uploader) { Deliver::UploadMetadata.new(options) }

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

        uploader.load_from_filesystem
        languages = uploader.detect_languages

        expect(languages.sort).to eql(['de-DE', 'el', 'en-US'])
      end

      it "languages are 'en-US', 'default'" do
        options[:languages] = []

        create_filesystem_language('default')
        create_filesystem_language('en-US')

        uploader.load_from_filesystem
        languages = uploader.detect_languages

        expect(languages.sort).to eql(['default', 'en-US'])
      end
    end

    context "detected languages with only config options" do
      it "languages are 'en-AU', 'en-CA', 'en-GB'" do
        options[:languages] = ['en-AU', 'en-CA', 'en-GB']

        uploader.load_from_filesystem
        languages = uploader.detect_languages

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

        uploader.load_from_filesystem
        languages = uploader.detect_languages

        expect(languages.sort).to eql(['default', 'es-MX'])
      end
    end

    context 'detect languages with file system with default folder' do
      it "languages are 'en-US', 'default'" do
        options[:languages] = []

        create_filesystem_language('default')
        create_filesystem_language('en-US')
        create_metadata(
          File.join(tmpdir, 'default', "#{Deliver::UploadMetadata::LOCALISED_VERSION_VALUES[:description]}.txt"),
          'something'
        )

        uploader.load_from_filesystem
        languages = uploader.detect_languages

        expect(languages.sort).to eql(['default', 'en-US'])
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

        uploader.load_from_filesystem
        languages = uploader.detect_languages

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

        uploader.load_from_filesystem
        uploader.assign_defaults

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
