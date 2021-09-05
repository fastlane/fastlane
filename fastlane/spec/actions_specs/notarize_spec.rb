describe Fastlane do
  describe Fastlane::FastFile do
    describe "notarize" do
      let(:success_submit_response) do
        {
         'status': 'Accepted',
         'id': '1111-2222-3333-4444'
        }.to_json
      end
      let(:invalid_submit_response) do
        {
         'status': 'Invalid',
         'statusSummary': 'Archive contains critical validation errors',
         'id': '1111-2222-3333-4444'
        }.to_json
      end

      context "with notary tool" do
        let(:package) { Tempfile.new('app.ipa.zip') }
        let(:bundle_id) { 'com.some.app' }

        context "with Apple ID" do
          let(:username) { 'myusername@example.com' }
          let(:asc_provider) { '123456789' }
          let(:app_specific_password) { 'secretpass' }

          it "successful" do
            stub_const('ENV', { "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password })

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --apple-id #{username} --password #{app_specific_password} --team-id #{asc_provider}", { error_callback: anything, log: false }).and_return(success_submit_response)

            expect(Fastlane::Actions).to receive(:sh).with("xcrun stapler staple #{package.path}", { log: false })

            result = Fastlane::FastFile.new.parse("lane :test do
              notarize(
                use_notarytool: true,
                package: '#{package.path}',
                bundle_id: '#{bundle_id}',
                username: '#{username}',
                asc_provider: '#{asc_provider}',
              )
            end").runner.execute(:test)
          end

          it "invalid" do
            stub_const('ENV', { "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password })

            expect(Fastlane::Actions).to receive(:sh).with("xcrun notarytool submit #{package.path} --output-format json --wait --apple-id #{username} --password #{app_specific_password} --team-id #{asc_provider}", { error_callback: anything, log: false }).and_return(invalid_submit_response)

            expect do
              result = Fastlane::FastFile.new.parse("lane :test do
                notarize(
                  use_notarytool: true,
                  package: '#{package.path}',
                  bundle_id: '#{bundle_id}',
                  username: '#{username}',
                  asc_provider: '#{asc_provider}',
                )
              end").runner.execute(:test)
            end.to raise_error(FastlaneCore::Interface::FastlaneError, "Could not notarize package with message 'Archive contains critical validation errors'")
          end
        end
      end
    end
  end
end
