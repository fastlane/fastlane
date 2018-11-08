describe Fastlane do
  describe Fastlane::FastFile do
    describe 'request_reviewers' do
      let(:response_body) { File.read('./fastlane/spec/fixtures/requests/github_request_reviewers_response.json') }
      
      context 'required data is sent' do
        before do
          stub_request(:post, 'https://api.github.com/repos/octocat/Hello-World/pulls/1347/requested_reviewers').
          with(body: '{"reviewers":["octocat","hubot","other_user"],"team_reviewers":["justice-league"]}').
          to_return(status: 201, body: response_body)
        end

        context 'passing all parameters' do
          data = "lane :test do
            request_reviewers(
              api_token: '123456789',
              repo: 'octocat/Hello-World',
              number: 1347,
              reviewers: ['octocat', 'hubot', 'other_user'],
              team_reviewers: ['justice-league']
            )
          end"
  
          it 'correctly submits to github' do
            result = Fastlane::FastFile.new.parse(data).runner.execute(:test)
            expect(result).to eq('https://github.com/octocat/Hello-World/pull/1347')
          end
        end
  
        context 'from pull request page' do
          data = "lane :test do
            lane_context[SharedValues::CREATE_PULL_REQUEST_HTML_URL] = 'https://github.com/octocat/Hello-World/pull/1347'
            request_reviewers(
              api_token: '123456789',
              reviewers: ['octocat', 'hubot', 'other_user'],
              team_reviewers: ['justice-league']
            )
          end"
  
          it 'correctly submits to github' do
            result = Fastlane::FastFile.new.parse(data).runner.execute(:test)
            expect(result).to eq('https://github.com/octocat/Hello-World/pull/1347')
          end
        end
      end

      context 'required data is not sent' do
        context 'passing the parameters' do
          before do
            stub_request(:post, 'https://api.github.com/repos/octocat/Hello-World/pulls/1347/requested_reviewers').
            with(body: '{"reviewers":null,"team_reviewers":null}').
            to_return(status: 422)
          end

          data = "lane :test do
            request_reviewers(
              api_token: '123456789',
              repo: 'octocat/Hello-World',
              number: 1347
            )
          end"
  
          it 'fails to submit to github' do
            result = Fastlane::FastFile.new.parse(data).runner.execute(:test)
            expect(result).to be(nil)
          end
        end

        context 'from pull request page' do
          before do
            stub_request(:post, 'https://api.github.com/repos//pulls//requested_reviewers').
            with(body: '{"reviewers":null,"team_reviewers":null}').
            to_return(status: 404)
          end

          data = "lane :test do
            request_reviewers(
              api_token: '123456789'
            )
          end"
  
          it 'fails to submit to github' do
            result = Fastlane::FastFile.new.parse(data).runner.execute(:test)
            expect(result).to be(nil)
          end
        end
      end
    end
  end
end
