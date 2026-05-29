describe Fastlane do
  describe Fastlane::FastFile do
    describe 'onesignal' do
      let(:app_id) { 'id123' }
      let(:app_name) { 'My App' }

      before :each do
        stub_const('ENV', { 'ONE_SIGNAL_AUTH_KEY' => 'auth-123' })
      end

      context 'when params are valid' do
        before :each do
          allow(FastlaneCore::UI).to receive(:success).with('Driving the lane \'test\' 🚀')
        end

        context 'and is create' do
          before :each do
            stub_request(:post, 'https://api.onesignal.com/apps').to_return(status: 200, body: '{}')
          end

          it 'outputs success message' do
            expect(FastlaneCore::UI).to receive(:message).with("Parameter App name: #{app_name}")
            expect(FastlaneCore::UI).to receive(:success).with('Successfully created new OneSignal app')

            Fastlane::FastFile.new.parse("lane :test do
              onesignal(app_name: '#{app_name}')
            end").runner.execute(:test)
          end
        end

        context 'and is update' do
          before :each do
            stub_request(:put, "https://api.onesignal.com/apps/#{app_id}").to_return(status: 200, body: '{}')
          end

          it 'outputs success message' do
            expect(FastlaneCore::UI).to receive(:message).with("Parameter App ID: #{app_id}")
            expect(FastlaneCore::UI).to receive(:success).with('Successfully updated OneSignal app')

            Fastlane::FastFile.new.parse("lane :test do
              onesignal(app_id: '#{app_id}')
            end").runner.execute(:test)
          end

          context 'with name' do
            it 'outputs success message' do
              expect(FastlaneCore::UI).to receive(:message).with("Parameter App ID: #{app_id}")
              expect(FastlaneCore::UI).to receive(:message).with("Parameter App name: #{app_name}")
              expect(FastlaneCore::UI).to receive(:success).with('Successfully updated OneSignal app')

              Fastlane::FastFile.new.parse("lane :test do
                onesignal(app_id: '#{app_id}', app_name: '#{app_name}')
              end").runner.execute(:test)
            end
          end
        end
      end

      context 'when params are not valid' do
        it 'outputs error message' do
          expect do
            Fastlane::FastFile.new.parse('lane :test do
              onesignal()
            end').runner.execute(:test)
          end.to raise_error(FastlaneCore::Interface::FastlaneError) do |error|
            expect(error.message).to eq('Please specify the `app_id` or the `app_name` parameters!')
          end
        end
      end
    end
  end
end
