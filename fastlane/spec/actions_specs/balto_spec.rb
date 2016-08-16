describe Fastlane do
  describe Fastlane::FastFile do
    describe "Balto Integration" do
      before do
        stub_request(:post, Fastlane::Actions::BaltoHelper.upload_url.to_s).
          to_return(status: 200, body: "{ \"build\":{
                    \"version_name\":\"2.3.0\",\"user_id\":134,
                    \"uploader\":{\"updated_at\":\"2016-05-20T07:25:47\",\"name\":\"balto\",\"inserted_at\":\"2016-05-20T07:25:47\",\"id\":134,\"email\":\"balto@example.com\",\"display_name\":\"Balto\",\"avatar_url\":\"https://avatars.example.com/u/217229?v=3\"},
                    \"release_note\":\"What's new in this release: \\nBalto action\\n\",
                    \"ready_for_review\":false,
                    \"project_id\":113,\"platform\":1,\"organization_id\":2,\"numbering\":18,\"inserted_at\":\"2016-07-30T12:40:44\",
                    \"id\":\"B0A0E8CF-EF76-498D-9BF8-43A7026BAF3F\",
                    \"icon_url\":\"https://example.com/balto/projects/113/builds/B0A0E8CF-EF76-498D-9BF8-43A7026BAF3F/AppIcon60x60@2x.png\",\"file_byte_size\":43781415,
                    \"feedback\":[],\"download_url\":\"itms-services://?action=download-manifest&url=https://example.com/balto/projects/113/builds/B0A0E8CF-EF76-498D-9BF8-43A7026BAF3F/app.plist\",\"app_identifier\":\"io.balto.app\"}}")
      end

      describe "Invalid Parameters" do
        context "No Parameters were given" do
          it do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                                           balto({})
                                           end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError)
          end
        end

        context "No tokens were given" do
          it do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                                           balto({
                                             ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1'
                                           })
                                           end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError)
          end
        end

        context "No Project token was given" do
          it do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                                           balto({
                                             ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                                             user_token: 'balto_user_token'
                                           })
                                           end").runner.execute(:test)
            end.to raise_error("No Project token for BaltoAction given, pass using `project_token: 'token'`")
          end
        end

        context "No User token was given" do
          it do
            expect do
              Fastlane::FastFile.new.parse("lane :test do
                                           balto({
                                             ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                                             project_token: 'balto_project_token'
                                           })
                                           end").runner.execute(:test)
            end.to raise_error("No User token for BaltoAction given, pass using `user_token: 'token'`")
          end
        end
      end

      describe "Works BaltoAction" do
        context "Valid parameters" do
          subject(:cmd_exec) do
            Fastlane::FastFile.new.parse("lane :test do
                                         balto({
                                           ipa_path: './fastlane/spec/fixtures/fastfiles/Fastfile1',
                                           user_token: 'balto_user_token',
                                           project_token: 'balto_project_token'
                                         })
                                         end").runner.execute(:test)
          end

          describe "The Result" do
            it do
              result = cmd_exec
              expect(result).not_to be_nil
            end
          end
        end
      end
    end
  end
end
