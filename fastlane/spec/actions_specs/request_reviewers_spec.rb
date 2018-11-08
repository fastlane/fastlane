describe Fastlane do
  describe Fastlane::FastFile do
    describe "request_reviewers" do
      let(:response_body) { File.read("./fastlane/spec/fixtures/requests/github_request_reviewers_response.json") }

      context 'successful' do
        before do
          stub_request(:post, "https://api.github.com/repos/octocat/Hello-World/pulls/1347/requested_reviewers").
            with(
              body: '{"reviewers":["octocat","hubot","other_user"],"team_reviewers":["justice-league"]}',
              headers: {
                'Authorization' => 'Basic MTIzNDU2Nzg5',
                'Host' => 'api.github.com:443',
                'User-Agent' => 'fastlane-github_api'
              }
            ).to_return(status: 201, body: response_body, headers: {})
        end

        it 'correctly submits to github' do
          result = Fastlane::FastFile.new.parse("
            lane :test do
              request_reviewers(
                api_token: '123456789',
                repo: 'octocat/Hello-World',
                number: 1347,
                reviewers: ['octocat', 'hubot', 'other_user'],
                team_reviewers: ['justice-league']
              )
            end
          ").runner.execute(:test)

          expect(result).to eq('https://github.com/octocat/Hello-World/pull/1347')
        end
      end
    end
  end
end
