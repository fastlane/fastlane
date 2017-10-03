describe Fastlane do
  describe Fastlane::FastFile do
    describe 'VerifyTwoStepSessionAction' do
      before do
        allow(Spaceship::Tunes).to receive(:login).and_return(true)
        allow(FastlaneCore::UI).to receive(:success)
        date = DateTime.new(2017, 10, 3, 1, 23, 45)
        allow(DateTime).to receive(:now).and_return(date)
      end

      context 'when loading cookie from environment variables' do
        it 'displays the expiration date and the remaining day correctly.' do
          cookie = YAML.safe_load(
            File.read('fastlane/spec/fixtures/actions/cookie_env').gsub("\\n", "\n"),
            [HTTP::Cookie, Time],
            [],
            true
          )
          expect(FastlaneCore::UI).to receive(:important).with(/expire at 2017-10-21 09:35:31 \(18 days left\)./)
          Fastlane::Actions::VerifyTwoStepSessionAction.check_expiration_time(cookie)
        end
      end

      context 'when loading cookie from file' do
        it 'displays the expiration date and the remaining day correctly.' do
          cookie = YAML.safe_load(
            File.read('fastlane/spec/fixtures/actions/cookie'),
            [HTTP::Cookie, Time],
            [],
            true
          )
          expect(FastlaneCore::UI).to receive(:important).with(/expire at 2017-11-02 13:14:27 \(30 days left\)./)
          Fastlane::Actions::VerifyTwoStepSessionAction.check_expiration_time(cookie)
        end
      end

      context 'when the expiration date is today' do
        before do
          date = DateTime.new(2017, 11, 2, 1, 23, 45)
          allow(DateTime).to receive(:now).and_return(date)
        end
        it 'displays the expiration date and the remaining day correctly.' do
          cookie = YAML.safe_load(
            File.read('fastlane/spec/fixtures/actions/cookie'),
            [HTTP::Cookie, Time],
            [],
            true
          )
          expect(FastlaneCore::UI).to receive(:error).with("Your session cookie is due to expire today!")
          Fastlane::Actions::VerifyTwoStepSessionAction.check_expiration_time(cookie)
        end
      end
    end
  end
end
