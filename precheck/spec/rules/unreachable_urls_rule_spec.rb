require 'precheck'

module Precheck
  describe Precheck do
    describe Precheck::UnreachableURLRule do
      let(:rule) { UnreachableURLRule.new }

      def setup_url_rule_mock(url: "http://fastlane.tools", return_status: 200)
        request = "fake request"
        head_object = "fake head object"

        allow(head_object).to receive(:status).and_return(return_status)

        allow(request).to receive(:use).and_return(nil)
        allow(request).to receive(:adapter).and_return(nil)
        allow(request).to receive(:head).and_return(head_object)

        allow(Faraday).to receive(:new).with(url).and_return(request)
      end

      it "passes for 200 status URL" do
        setup_url_rule_mock
        item = URLItemToCheck.new("http://fastlane.tools", "some_url", "test URL")
        result = rule.check_item(item)

        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "passes for valid non encoded URL" do
        setup_url_rule_mock(url: "http://fastlane.tools/%E3%83%86%E3%82%B9%E3%83%88")

        item = URLItemToCheck.new("http://fastlane.tools/テスト", "some_url", "test URL")
        result = rule.check_item(item)

        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "fails for anything else" do
        setup_url_rule_mock(return_status: 500)
        item = URLItemToCheck.new("http://fastlane.tools", "some_url", "test URL")

        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("http://fastlane.tools")

        setup_url_rule_mock(return_status: 404)
        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("http://fastlane.tools")

        setup_url_rule_mock(return_status: 409)
        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("http://fastlane.tools")

        setup_url_rule_mock(return_status: 403)
        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("http://fastlane.tools")
      end

      it "fails if not optional and URL is nil" do
        setup_url_rule_mock
        item = URLItemToCheck.new(nil, "some_url", "test URL", false)

        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("empty url")
      end

      it "fails if not optional and URL is empty" do
        setup_url_rule_mock
        item = URLItemToCheck.new("", "some_url", "test URL", false)

        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:failed])
        expect(result.rule_return.failure_data).to eq("empty url")
      end

      it "passes if empty and optional is true" do
        setup_url_rule_mock
        item = URLItemToCheck.new("", "some_url", "test URL", true)

        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end

      it "passes if nil and optional is true" do
        setup_url_rule_mock
        item = URLItemToCheck.new(nil, "some_url", "test URL", true)

        result = rule.check_item(item)
        expect(result.status).to eq(VALIDATION_STATES[:passed])
      end
    end
  end
end
