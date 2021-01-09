require 'deliver/setup'

describe Deliver do
  describe Deliver::Setup do
    describe '#generate_metadata_files' do
      context 'with review_information' do
        let(:setup) { Deliver::Setup.new }
        let(:tempdir) { Dir.mktmpdir }

        let(:app) { double('app') }
        let(:app_info) do
          double('app_info',
                 primary_category: double('primary_category', id: 'cat1'),
                 primary_subcategory_one: double('primary_subcategory_one', id: 'cat1sub1'),
                 primary_subcategory_two: double('primary_subcategory_two', id: 'cat1sub2'),
                 secondary_category: double('secondary_category', id: 'cat2'),
                 secondary_subcategory_one: double('secondary_subcategory_one', id: 'cat2sub1'),
                 secondary_subcategory_two: double('secondary_subcategory_two', id: 'cat2sub2'))
        end
        let(:app_info_localization_en) do
          double('app_info_localization_en',
                 locale: "en-US",
                 name: "fastlane",
                 subtitle: "the fastest lane",
                 privacy_policy_url: "https://fastlane.tools/privacy/en",
                 privacy_policy_text: "fastlane privacy en")
        end
        let(:version) do
          double('version',
                 copyright: "2020 fastlane")
        end
        let(:version_localization_en) do
          double('version',
                 description: "description en",
                 locale: "en-US",
                 keywords: "app version en",
                 marketing_url: "https://fastlane.tools/en",
                 promotional_text: "promotional text en",
                 support_url: "https://fastlane.tools/support/en",
                 whats_new: "whats new en")
        end
        let(:app_review_detail) do
          double('app_review_detail',
                 contact_first_name: 'John',
                 contact_last_name: 'Smith',
                 contact_phone: '+819012345678',
                 contact_email: 'deliver@example.com',
                 demo_account_name: 'user',
                 demo_account_password: 'password',
                 notes: 'This is a note')
        end

        before do
          allow(app).to receive(:fetch_live_app_info).and_return(app_info)
          allow(app_info).to receive(:get_app_info_localizations).and_return([app_info_localization_en])

          allow(version).to receive(:get_app_store_version_localizations).and_return([version_localization_en])
          allow(version).to receive(:fetch_app_store_review_detail).and_return(app_review_detail)
        end

        it 'generates metadata' do
          map = {
            "copyright" => "2020 fastlane",
            "primary_category" => "cat1",
            "secondary_category" => "cat2",
            "primary_first_sub_category" => "cat1sub1",
            "primary_second_sub_category" => "cat1sub2",
            "secondary_first_sub_category" => "cat2sub1",
            "secondary_second_sub_category" => "cat2sub2",

            "en-US/description" => "description en",
            "en-US/keywords" => "app version en",
            "en-US/release_notes" => "whats new en",
            "en-US/support_url" => "https://fastlane.tools/support/en",
            "en-US/marketing_url" => "https://fastlane.tools/en",
            "en-US/promotional_text" => "promotional text en",

            "review_information/first_name" => "John",
            "review_information/last_name" => "Smith",
            "review_information/phone_number" => "+819012345678",
            "review_information/email_address" => "deliver@example.com",
            "review_information/demo_user" => "user",
            "review_information/demo_password" => "password",
            "review_information/notes" => "This is a note"
          }

          setup.generate_metadata_files(app, version, tempdir)
          base_dir = File.join(tempdir)
          map.each do |filename, value|
            path = File.join(base_dir, "#{filename}.txt")
            expect(File.exist?(path)).to be_truthy, " for #{path}"
            expect(File.read(path).strip).to eq(value)
          end
        end

        after do
          FileUtils.remove_entry_secure(tempdir)
        end
      end
    end
  end
end
