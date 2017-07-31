describe Fastlane do
  describe Fastlane::FastFile do
    describe "commit_github_file" do
      let(:response_body) { File.read("./fastlane/spec/fixtures/requests/github_create_file_response.json") }

      context 'successful' do
        before do
          stub_request(:put, "https://api.github.com/repos/fastlane/fastlane/contents/test/assets/TEST_FILE.md").
            with(body: "{\"path\":\"/test/assets/TEST_FILE.md\",\"message\":\"Add my new file\",\"content\":\"dGVzdA==\\n\",\"branch\":\"master\"}",
              headers: {
                'Authorization' => 'Basic MTIzNDVhYmNkZQ==',
                'Host' => 'api.github.com:443',
                'User-Agent' => 'fastlane-github_api'
              }).
            to_return(status: 200, body: response_body, headers: {})
        end

        it 'correctly submits to github' do
          path = '/test/assets/TEST_FILE.md'
          content = 'test'
          allow(File).to receive(:exist?).with(path).and_return(true).at_least(:once)
          allow(File).to receive(:exist?).and_return(:default)
          allow(File).to receive(:open).with(path).and_return(StringIO.new(content))

          result = Fastlane::FastFile.new.parse("
            lane :test do
              commit_github_file(
                api_token: '12345abcde',
                repository_name: 'fastlane/fastlane',
                message: 'Add my new file',
                path: '/test/assets/TEST_FILE.md'
              )
            end
          ").runner.execute(:test)

          expect(result['content']['url']).to eq('https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md?ref=test-branch')
          expect(result['commit']['sha']).to eq('faa361b0c282fca74e2170bcb4ac3ec577fd2922')
        end
      end
    end
  end
end
