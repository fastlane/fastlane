require 'fastlane_core/update_checker'

def mock_ruby_gems_response(version)
  # RubyGems API to verify the latest app version
    stub_request(:get, "https://fastlane-refresher.herokuapp.com/deliver").
      with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => {version: version}.to_json, :headers => {})
end

describe FastlaneCore do
  describe FastlaneCore::UpdateChecker do
    let (:name) { 'deliver' }

    describe "#update_available?" do
      it "no update is available" do
        mock_ruby_gems_response("0.1")
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.11')).to eq(false)
      end

      it "new update is available" do
        mock_ruby_gems_response("999.0")
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.11')).to eq(true)
      end

      it "same version" do
        mock_ruby_gems_response(FastlaneCore::VERSION)
        expect(FastlaneCore::UpdateChecker.update_available?(name, FastlaneCore::VERSION)).to eq(false)
      end

      it "new pre-release" do
        mock_ruby_gems_response([FastlaneCore::VERSION, 'pre'].join("."))
        expect(FastlaneCore::UpdateChecker.update_available?(name, FastlaneCore::VERSION)).to eq(false)
      end

      it "current: Pre-Release - new official version" do
        mock_ruby_gems_response('0.9.1')
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.1.pre')).to eq(true)
      end

      it "a new pre-release when pre-release is installed" do
        mock_ruby_gems_response('0.9.1.pre2')
        expect(FastlaneCore::UpdateChecker.update_available?(name, '0.9.1.pre1')).to eq(true)
      end
    end
  end
end