describe Fastlane do
  describe Fastlane::FastFile do
    describe "github_api" do
      let(:response_body) { File.read("./fastlane/spec/fixtures/requests/github_create_file_response.json") }
      let(:user_agent) { 'fastlane-github_api' }
      let(:headers) do
        {
          'Authorization' => 'Basic MTIzNDU2Nzg5',
          'Host' => 'api.github.com:443',
          'User-Agent' => user_agent
        }
      end

      context 'successful' do
        before do
          stub_request(:put, "https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md").
            with(headers: headers).
            to_return(status: 200, body: response_body, headers: {})
        end

        context 'with a hash body' do
          it 'correctly submits to github api' do
            result = Fastlane::FastFile.new.parse("
              lane :test do
                github_api(
                  api_token: '123456789',
                  http_method: 'PUT',
                  path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                  body: {
                    path: 'TEST_FILE.md',
                    message: 'File committed',
                    content: 'VGVzdCBDb250ZW50Cg==\n',
                    branch: 'test-branch'
                  }
                )
              end
            ").runner.execute(:test)

            expect(result[:status]).to eq(200)
            expect(result[:body]).to eq(response_body)
            expect(result[:json]).to eq(JSON.parse(response_body))
          end
        end

        context 'with raw JSON body' do
          it 'correctly submits to github api' do
            result = Fastlane::FastFile.new.parse(%{
              lane :test do
                github_api(
                  api_token: '123456789',
                  http_method: 'PUT',
                  path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                  body: '{
                      "path":"TEST_FILE.md",
                      "message":"File committed",
                      "content":"VGVzdCBDb250ZW50Cg==\\\\n",
                      "branch":"test-branch"
                    }'
                  )
              end
            }).runner.execute(:test)

            expect(result[:status]).to eq(200)
            expect(result[:body]).to eq(response_body)
            expect(result[:json]).to eq(JSON.parse(response_body))
          end
        end

        it 'allows calling as a block for success from other actions' do
          expect do
            Fastlane::FastFile.new.parse(%{
              lane :test do
                Fastlane::Actions::GithubApiAction.run(
                  server_url: 'https://api.github.com',
                  api_token: '123456789',
                  http_method: 'PUT',
                  path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                  body: '{
                      "path":"TEST_FILE.md",
                      "message":"File committed",
                      "content":"VGVzdCBDb250ZW50Cg==\\\\n",
                      "branch":"test-branch"
                    }'
                  ) do |result|
                    UI.user_error!("Success block triggered with \#{result[:body]}")
                  end
              end
            }).runner.execute(:test)
          end.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match("Success block triggered with #{response_body}")
            end
          )
        end

        context 'optional params' do
          let(:response_body) { File.read("./fastlane/spec/fixtures/requests/github_upload_release_asset_response.json") }
          let(:headers) do
            {
              'Authorization' => 'Basic MTIzNDU2Nzg5',
              'Host' => 'uploads.github.com:443',
              'User-Agent' => user_agent
            }
          end

          before do
            stub_request(:post, "https://uploads.github.com/repos/fastlane/fastlane/releases/1/assets?name=TEST_FILE.md").
              with(body: "test raw content of file",
                 headers: headers).
              to_return(status: 200, body: response_body, headers: {})
          end

          context 'full url and raw body' do
            it 'allows overrides and sends raw full values' do
              result = Fastlane::FastFile.new.parse(%{
                lane :test do
                  github_api(
                    api_token: '123456789',
                    http_method: 'POST',
                    url: 'https://uploads.github.com/repos/fastlane/fastlane/releases/1/assets?name=TEST_FILE.md',
                    raw_body: 'test raw content of file'
                    )
                end
              }).runner.execute(:test)

              expect(result[:status]).to eq(200)
              expect(result[:body]).to eq(response_body)
              expect(result[:json]).to eq(JSON.parse(response_body))
            end
          end

          context 'overridable headers' do
            let(:headers) do
              {
                'Authorization' => 'custom',
                'Host' => 'uploads.github.com:443',
                'User-Agent' => 'fastlane-custom-user-agent',
                'Content-Type' => 'text/plain'
              }
            end

            it 'allows calling with custom headers and override auth' do
              result = Fastlane::FastFile.new.parse(%{
                lane :test do
                  github_api(
                    api_token: '123456789',
                    http_method: 'POST',
                    headers: {
                      'Content-Type' => 'text/plain',
                      'Authorization' => 'custom',
                      'User-Agent' => 'fastlane-custom-user-agent'
                    },
                    url: 'https://uploads.github.com/repos/fastlane/fastlane/releases/1/assets?name=TEST_FILE.md',
                    raw_body: 'test raw content of file'
                    )
                end
              }).runner.execute(:test)

              expect(result[:status]).to eq(200)
              expect(result[:body]).to eq(response_body)
              expect(result[:json]).to eq(JSON.parse(response_body))
            end
          end
        end

        context "url isn't set" do
          context "path is set, server_url isn't set" do
            it "uses default server_url" do
              expect do
                result = Fastlane::FastFile.new.parse("
                  lane :test do
                    github_api(
                      api_token: '123456789',
                      http_method: 'PUT',
                      path: 'repos/fastlane/fastlane/contents/TEST_FILE.md'
                    )
                  end
                ").runner.execute(:test)
                expect(result[:status]).to eq(200)
                expect(result[:html_url]).to eq("https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md")
              end
            end
          end

          context "path and server_url are set" do
            it "correctly submits by building the full url from server_url and path" do
              expect do
                result = Fastlane::FastFile.new.parse("
                    lane :test do
                      github_api(
                        api_token: '123456789',
                        http_method: 'PUT',
                        path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                        server_url: 'https://api.github.com'
                      )
                    end
                  ").runner.execute(:test)
                expect(result[:status]).to eq(200)
                expect(result[:html_url]).to eq("https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md")
              end
            end
          end
        end

        context "url is set" do
          context "path and server_url are set" do
            it "correctly submits using the path and server_url instead of the url" do
              expect do
                result = Fastlane::FastFile.new.parse("
                    lane :test do
                      github_api(
                        api_token: '123456789',
                        http_method: 'PUT',
                        url: 'https://api.github.com/repos/fastlane/fastlane/contents/NONEXISTENT_TEST_FILE.md',
                        path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                        server_url: 'https://api.github.com'
                      )
                    end
                  ").runner.execute(:test)

                expect(result[:status]).to eq(200)
                expect(result[:html_url]).to eq("https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md")
                expect(result[:html_url]).to_not(eq("https://api.github.com/repos/fastlane/fastlane/contents/NONEXISTENT_TEST_FILE.md"))
              end
            end
          end

          context "path and server_url aren't set" do
            it "correctly submits using the full url" do
              expect do
                result = Fastlane::FastFile.new.parse("
                    lane :test do
                      github_api(
                        api_token: '123456789',
                        http_method: 'PUT',
                        url: 'https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md'
                      )
                    end
                  ").runner.execute(:test)

                expect(result[:status]).to eq(200)
                expect(result[:html_url]).to eq("https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md")
              end
            end
          end
        end
      end

      context 'failures' do
        let(:error_response_body) { '{"message":"Bad credentials","documentation_url":"https://developer.github.com/v3"}' }

        before do
          stub_request(:put, "https://api.github.com/repos/fastlane/fastlane/contents/TEST_FILE.md").
            with(headers: {
                    'Authorization' => 'Basic MTIzNDU2Nzg5',
                    'Host' => 'api.github.com:443',
                    'User-Agent' => 'fastlane-github_api'
                  }).
            to_return(status: 401, body: error_response_body, headers: {})
        end

        it "raises on error by default" do
          expect do
            Fastlane::FastFile.new.parse("
              lane :test do
                github_api(
                  api_token: '123456789',
                  http_method: 'PUT',
                  path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                  body: {
                    path: 'TEST_FILE.md',
                    message: 'File committed',
                    content: 'VGVzdCBDb250ZW50Cg==\n',
                    branch: 'test-branch'
                  }
                )
              end
            ").runner.execute(:test)
          end.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match("GitHub responded with 401")
            end
          )
        end

        it "allows custom error handling by status code" do
          expect do
            Fastlane::FastFile.new.parse("
              lane :test do
                github_api(
                  api_token: '123456789',
                  http_method: 'PUT',
                  path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                  body: {
                    path: 'TEST_FILE.md',
                    message: 'File committed',
                    content: 'VGVzdCBDb250ZW50Cg==\n',
                    branch: 'test-branch'
                  },
                  error_handlers: {
                    401 => proc {|result|
                      UI.user_error!(\"Custom error handled for 401 \#{result[:body]}\")
                    },
                    404 => proc do |result|
                      UI.message('not found')
                    end
                  }
                )
              end
            ").runner.execute(:test)
          end.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match("Custom error handled for 401 #{error_response_body}")
            end
          )
        end

        it "allows custom error handling for all other errors" do
          expect do
            Fastlane::FastFile.new.parse("
              lane :test do
                github_api(
                  api_token: '123456789',
                  http_method: 'PUT',
                  path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                  body: {
                    path: 'TEST_FILE.md',
                    message: 'File committed',
                    content: 'VGVzdCBDb250ZW50Cg==\n',
                    branch: 'test-branch'
                  },
                  error_handlers: {
                    '*' => proc do |result|
                      UI.user_error!(\"Custom error handled for all errors\")
                    end,
                    404 => proc do |result|
                      UI.message('not found')
                    end
                  }
                )
              end
            ").runner.execute(:test)
          end.to(
            raise_error(FastlaneCore::Interface::FastlaneError) do |error|
              expect(error.message).to match("Custom error handled for all errors")
            end
          )
        end

        it "doesn't raise on custom error handling" do
          result = Fastlane::FastFile.new.parse("
            lane :test do
              github_api(
                api_token: '123456789',
                http_method: 'PUT',
                path: 'repos/fastlane/fastlane/contents/TEST_FILE.md',
                body: {
                  path: 'TEST_FILE.md',
                  message: 'File committed',
                  content: 'VGVzdCBDb250ZW50Cg==\n',
                  branch: 'test-branch'
                },
                error_handlers: {
                  401 => proc do |result|
                    UI.message(\"error handled\")
                  end
                }
              )
            end
          ").runner.execute(:test)

          expect(result[:status]).to eq(401)
          expect(result[:body]).to eq(error_response_body)
          expect(result[:json]).to eq(JSON.parse(error_response_body))
        end

        context "url isn't set" do
          context "path isn't set, server_url is set" do
            it "raises" do
              expect do
                Fastlane::FastFile.new.parse("
                  lane :test do
                    github_api(
                      api_token: '123456789',
                      http_method: 'PUT',
                      server_url: 'https://api.github.com'
                    )
                  end
                ").runner.execute(:test)
              end.to(
                raise_error(FastlaneCore::Interface::FastlaneError) do |error|
                  expect(error.message).to match("Please provide either `server_url` (e.g. https://api.github.com) and 'path' or full 'url' for GitHub API endpoint")
                end
              )
            end
          end
        end
      end
    end
  end
end
