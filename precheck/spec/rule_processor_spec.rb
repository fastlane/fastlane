require 'precheck'
require 'spaceship'
require 'webmock'

describe Precheck do
  describe Precheck::RuleProcessor do
    let(:fake_happy_app) { "fake_app_object" }
    let(:fake_happy_app_details) { "fake_app_details" }
    let(:fake_happy_app_version) { "fake_app_version_object" }
    let(:fake_in_app_purchase) { "fake_in_app_purchase" }
    let(:fake_in_app_purchase_edit) { "fake_in_app_purchase_edit" }
    let(:fake_in_app_purchase_edit_version) { { :"de-DE" => { name: "iap name", description: "iap desc" } } }
    let(:fake_in_app_purchases) { [fake_in_app_purchase] }

    before do
      setup_happy_app
      config = FastlaneCore::Configuration.create(Precheck::Options.available_options, {})
      Precheck.config = config
    end

    def setup_happy_app
      allow(fake_happy_app).to receive(:apple_id).and_return("com.whatever")
      allow(fake_happy_app).to receive(:name).and_return("My Fake App")
      allow(fake_happy_app).to receive(:in_app_purchases).and_return(fake_in_app_purchases)
      allow(fake_happy_app).to receive(:details).and_return(fake_happy_app_details)

      allow(fake_happy_app_details).to receive(:name).and_return(fake_language_item_for_text_item(fieldname: "name"))
      allow(fake_happy_app_details).to receive(:apple_tv_privacy_policy).and_return(fake_language_item_for_text_item(fieldname: "apple_tv_privacy_policy"))
      allow(fake_happy_app_details).to receive(:subtitle).and_return(fake_language_item_for_text_item(fieldname: "subtitle"))
      allow(fake_happy_app_details).to receive(:privacy_url).and_return(fake_language_item_for_url_item(fieldname: "privacy_url"))

      allow(fake_happy_app_version).to receive(:copyright).and_return("Copyright taquitos, #{DateTime.now.year}")
      allow(fake_happy_app_version).to receive(:keywords).and_return(fake_language_item_for_text_item(fieldname: "keywords"))
      allow(fake_happy_app_version).to receive(:description).and_return(fake_language_item_for_text_item(fieldname: "description"))
      allow(fake_happy_app_version).to receive(:release_notes).and_return(fake_language_item_for_text_item(fieldname: "release_notes"))
      allow(fake_happy_app_version).to receive(:support_url).and_return(fake_language_item_for_url_item(fieldname: "support_url"))
      allow(fake_happy_app_version).to receive(:marketing_url).and_return(fake_language_item_for_url_item(fieldname: "marketing_url"))

      allow(fake_in_app_purchases).to receive(:all).and_return(fake_in_app_purchases)
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
