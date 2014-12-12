require 'deliver/update_checker'

def mock_ruby_gems_response(version)
  # RubyGems API to verify the latest app version
    stub_request(:get, "http://rubygems.org/api/v1/gems/deliver.json").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => {version: version}.to_json, :headers => {})
end

describe Deliver do
  describe Deliver::UpdateChecker do
    describe "#verify_latest_version" do
      it "checks for the latest version" do
        expect(Deliver::UpdateChecker.verify_latest_version).to eq(false)
      end
    end

    describe "#update_available?" do
      it "no update is available" do
        mock_ruby_gems_response("0.1")
        expect(Deliver::UpdateChecker.update_available?).to eq(false)
      end

      it "new update is available" do
        mock_ruby_gems_response("999.0")
        expect(Deliver::UpdateChecker.update_available?).to eq(true)
        Deliver::UpdateChecker.verify_latest_version
      end

      it "same version" do
        mock_ruby_gems_response(Deliver::VERSION)
        expect(Deliver::UpdateChecker.update_available?).to eq(false)
      end

      it "new pre-release" do
        mock_ruby_gems_response([Deliver::VERSION, 'pre'].join("."))
        expect(Deliver::UpdateChecker.update_available?).to eq(false)
      end

      it "current: Pre-Release - new official version" do
        mock_ruby_gems_response('0.9.1')
        Deliver::UpdateChecker.stub(:current_version) { '0.9.1.pre' }
        expect(Deliver::UpdateChecker.update_available?).to eq(true)
      end

      it "a new pre-release when pre-release is installed" do
        mock_ruby_gems_response('0.9.1.pre2')
        Deliver::UpdateChecker.stub(:current_version) { '0.9.1.pre1' }
        expect(Deliver::UpdateChecker.update_available?).to eq(true)
      end
    end

    describe "#current_version" do
      it "returns the current version" do
        expect(Deliver::UpdateChecker.current_version).to eq(Deliver::VERSION)
      end
    end
  end
end