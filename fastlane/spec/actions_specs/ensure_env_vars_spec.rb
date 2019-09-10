describe Fastlane do
  describe Fastlane::FastFile do
    describe 'ensure_env_vars' do
      context 'when param is valid' do
        before :each do
          allow(FastlaneCore::UI).to receive(:success).with("Driving the lane 'test' 🚀")
        end

        context 'and env var is set' do
          before :each do
            allow(ENV).to receive(:[]).and_return('valid')
          end

          it 'outputs success message' do
            expect(FastlaneCore::UI).to receive(:success).with('Environment variable \'FIRST\' is set!')

            Fastlane::FastFile.new.parse('lane :test do
              ensure_env_vars(env_vars: [\'FIRST\'])
            end').runner.execute(:test)
          end
        end

        context 'and env vars are set' do
          before :each do
            allow(ENV).to receive(:[]).and_return('valid')
          end

          it 'outputs success message' do
            expect(FastlaneCore::UI).to receive(:success).with('Environment variables \'FIRST\', \'SECOND\' are set!')

            Fastlane::FastFile.new.parse('lane :test do
              ensure_env_vars(env_vars: [\'FIRST\', \'SECOND\'])
            end').runner.execute(:test)
          end
        end

        context 'and env var is not set' do
          it 'outputs error message' do
            expect(FastlaneCore::UI).to receive(:user_error!).with('Missing environment variable \'MISSING\'')

            Fastlane::FastFile.new.parse('lane :test do
              ensure_env_vars(env_vars: [\'MISSING\'])
            end').runner.execute(:test)
          end
        end

        context 'and env var is empty' do
          before :each do
            allow(ENV).to receive(:[]).and_return(' ')
          end

          it 'outputs error message' do
            expect(FastlaneCore::UI).to receive(:user_error!).with('Missing environment variable \'MISSING\'')

            Fastlane::FastFile.new.parse('lane :test do
              ensure_env_vars(env_vars: [\'MISSING\'])
            end').runner.execute(:test)
          end
        end
      end

      context 'when param is not valid' do
        context 'because no env var is passed' do
          it 'outputs error message' do
            expect(FastlaneCore::UI).to receive(:user_error!).with('Specify at least one environment variable name')

            Fastlane::FastFile.new.parse('lane :test do
              ensure_env_vars(env_vars: [])
            end').runner.execute(:test)
          end
        end
      end
    end
  end
end
