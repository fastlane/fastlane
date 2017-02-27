describe Fastlane do
  describe Fastlane::FastFile do
    describe "make_jenkins_changelog" do
      before do
        ENV['BUILD_URL'] = "https://jenkinsurl.com/JOB/"
      end

      after do
        ENV['BUILD_URL'] = nil
      end

      it "returns the fallback if it wasn't able to communicate with the server" do
        stub_request(:get, "https://jenkinsurl.com/JOB/api/json\?wrapper\=changes\&xpath\=//changeSet//comment").
          with(headers: { 'Host' => 'jenkinsurl.com' }).
          to_timeout

        result = Fastlane::FastFile.new.parse("lane :test do
          make_changelog_from_jenkins(fallback_changelog: 'FOOBAR')
        end").runner.execute(:test)

        expect(result).to eq("FOOBAR")
      end

      it "correctly parses the data if it was able to retrieve it and does not include the commit body" do
        stub_request(:get, "https://jenkinsurl.com/JOB/api/json\?wrapper\=changes\&xpath\=//changeSet//comment").
          with(headers: { 'Host' => 'jenkinsurl.com' }).
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/make_jenkins_changelog.json"), headers: {})

        result = Fastlane::FastFile.new.parse("lane :test do
          make_changelog_from_jenkins(fallback_changelog: 'FOOBAR', include_commit_body: false)
        end").runner.execute(:test)

        expect(result).to eq("Disable changelog generation from Jenkins until we sort it out\n")
      end

      it "correctly parses the data if it was able to retrieve it and include commit body" do
        stub_request(:get, "https://jenkinsurl.com/JOB/api/json\?wrapper\=changes\&xpath\=//changeSet//comment").
          with(headers: { 'Host' => 'jenkinsurl.com' }).
          to_return(status: 200, body: File.read("./fastlane/spec/fixtures/requests/make_jenkins_changelog.json"), headers: {})

        result = Fastlane::FastFile.new.parse("lane :test do
          make_changelog_from_jenkins(fallback_changelog: 'FOOBAR')
        end").runner.execute(:test)

        expect(result).to eq("Disable changelog generation from Jenkins until we sort it out\nThis commit has a body\n")
      end
    end
  end
end
