require 'precheck'
require 'spaceship'
require 'webmock'

describe Precheck do
  describe Precheck::RuleProcessor do
    let(:fake_happy_app) { "fake_app_object" }
    let(:fake_happy_app_version) { "fake_app_version_object" }
    let(:fake_happy_app_info) { "fake_app_info_object" }
    let(:fake_in_app_purchase) { "fake_in_app_purchase" }
    let(:fake_in_app_purchase_edit) { "fake_in_app_purchase_edit" }
    let(:fake_in_app_purchase_edit_version) { { "de-DE": { name: "iap name", description: "iap desc" } } }
    let(:fake_in_app_purchases) { [fake_in_app_purchase] }

    before do
      setup_happy_app
      config = FastlaneCore::Configuration.create(Precheck::Options.available_options, {})
      Precheck.config = config
    end

    def setup_happy_app
      allow(fake_happy_app).to receive(:id).and_return("3838204")
      allow(fake_happy_app).to receive(:name).and_return("My Fake App")
      allow(fake_happy_app).to receive(:in_app_purchases).and_return(fake_in_app_purchases)

      allow(fake_happy_app).to receive(:fetch_edit_app_info).and_return(fake_happy_app_info)
      allow(fake_happy_app_info).to receive(:get_app_info_localizations).and_return([fake_info_localization])

      allow(fake_happy_app_version).to receive(:copyright).and_return("Copyright taquitos, #{DateTime.now.year}")
      allow(fake_happy_app_version).to receive(:get_app_store_version_localizations).and_return([fake_version_localization])

      allow(Precheck::RuleProcessor).to receive(:get_iaps).and_return(fake_in_app_purchases)
      allow(fake_in_app_purchase).to receive(:edit).and_return(fake_in_app_purchase_edit)
      allow(fake_in_app_purchase_edit).to receive(:versions).and_return(fake_in_app_purchase_edit_version)

      setup_happy_url_rule_mock
    end

    def setup_happy_url_rule_mock
      request = "fake request"
      head_object = "fake head object"

      allow(head_object).to receive(:status).and_return(200)

      allow(request).to receive(:use).and_return(nil)
      allow(request).to receive(:adapter).and_return(nil)
      allow(request).to receive(:head).and_return(head_object)

      allow(Faraday).to receive(:new).and_return(request)
    end

    def fake_version_localization
      Spaceship::ConnectAPI::AppStoreVersionLocalization.new("id", {
        "description" =>  "hi! this is fake data",
        "locale" =>  "locale",
        "keywords" =>  "hi! this is fake data",
        "marketingUrl" =>  "http://fastlane.tools",
        "promotionalText" =>  "hi! this is fake data",
        "supportUrl" =>  "http://fastlane.tools",
        "whatsNew" =>  "hi! this is fake data"
      })
    end

    def fake_info_localization
      Spaceship::ConnectAPI::AppInfoLocalization.new("id", {
        "locale" => "locale",
        "name" => "hi! this is fake data",
        "subtitle" => "hi! this is fake data",
        "privacyPolicyUrl" => "http://fastlane.tools",
        "privacyPolicyText" => "hi! this is fake data"
      })
    end

    def fake_language_item_for_text_item(fieldname: nil)
      Spaceship::Tunes::LanguageItem.new(fieldname, [{ fieldname => { "value" => "hi! this is fake data" }, "language" => "en-US" }])
    end

    def fake_language_item_for_url_item(fieldname: nil)
      Spaceship::Tunes::LanguageItem.new(fieldname, [{ fieldname => { "value" => "http://fastlane.tools" }, "language" => "en-US" }])
    end

    it "successfully passes for happy values" do
      result = Precheck::RuleProcessor.process_app_and_version(
        app: fake_happy_app,
        app_version: fake_happy_app_version,
        rules: Precheck::Options.rules
      )

      expect(result.error_results).to eq({})
      expect(result.warning_results).to eq({})
      expect(result.skipped_rules).to eq([])
      expect(result.items_not_checked).to eq([])

      expect(result.should_trigger_user_error?).to be(false)
      expect(result.has_errors_or_warnings?).to be(false)
      expect(result.items_not_checked?).to be(false)
    end
  end
end
