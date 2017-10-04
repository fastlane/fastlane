describe Fastlane do
  describe Fastlane::FastFile do
    describe 'VerifyTwoStepSessionAction' do
      describe '#run' do
        context 'when InvalidUserCredentialsError has occurred' do
          before do
            allow(Spaceship::Tunes).to receive(:login).and_raise(Spaceship::Client::InvalidUserCredentialsError, "test message")
          end
          it 'raises InvalidUserCredentialsError' do
            expect { Fastlane::Actions::VerifyTwoStepSessionAction.run({ user: 'foo@example.com' }) }.to raise_error(FastlaneCore::Interface::FastlaneError, "test message")
          end
        end
        context 'when InvalidUserCredentialsError has occurred' do
          before do
            allow(Spaceship::Tunes).to receive(:login).and_raise(Spaceship::Client::NoUserCredentialsError)
          end
          it 'raises InvalidUserCredentialsError' do
            expect { Fastlane::Actions::VerifyTwoStepSessionAction.run({ user: 'foo@example.com' }) }.to raise_error(FastlaneCore::Interface::FastlaneError, "Your session cookie has been expired.")
          end
        end
      end

      describe '#check_expiration_time' do
        let(:expect_date) do
          expect_jst = Time.new("2017", "11", "02", "13", "14", "27", "+09:00")
          utc_offset = Time.new.strftime('%:z')
          expect_jst.getlocal(utc_offset).to_s
        end

        before do
          allow(Spaceship::Tunes).to receive(:login).and_return(true)
          allow(FastlaneCore::UI).to receive(:success)
          date = Time.new(2017, 10, 3, 1, 23, 45, '+09:00').utc
          allow(Time).to receive(:now).and_return(date)
        end

        # create: 2017-09-21 13:14:27 +09:00
        # expire: 2017-10-21 09:35:31 +09:00
        # now   : 2017-10-30 10:23:45 +09:00
        context 'when loading cookie from environment variables' do
          let(:expect_date) do
            expect_jst = Time.new("2017", "10", "21", "9", "35", "31", "+09:00")
            utc_offset = Time.new.strftime('%:z')
            expect_jst.getlocal(utc_offset).to_s
          end
          it 'displays the expiration date and the remaining day.' do
            cookie = YAML.safe_load(
              File.read('fastlane/spec/fixtures/actions/cookie_env').gsub("\\n", "\n"),
              [HTTP::Cookie, Time],
              [],
              true
            )
            expect(FastlaneCore::UI).to receive(:important).with("Your session cookie will expire at #{expect_date} (18 days left).")
            Fastlane::Actions::VerifyTwoStepSessionAction.check_expiration_time(cookie)
          end
        end

        # create: 2017-10-03 13:14:27 +09:00
        # expire: 2017-11-02 13:14:27 +09:00
        # now   : 2017-10-30 10:23:45 +09:00
        context 'when loading cookie from file' do
          it 'displays the expiration date and the remaining day.' do
            cookie = YAML.safe_load(
              File.read('fastlane/spec/fixtures/actions/cookie'),
              [HTTP::Cookie, Time],
              [],
              true
            )
            expect(FastlaneCore::UI).to receive(:important).with("Your session cookie will expire at #{expect_date} (30 days left).")
            Fastlane::Actions::VerifyTwoStepSessionAction.check_expiration_time(cookie)
          end
        end

        # create: 2017-10-03 13:14:27 +09:00
        # expire: 2017-11-02 13:14:27 +09:00
        # now   : 2017-10-30 10:23:45 +09:00
        context 'when the expiration date is 48 hour or less' do
          before do
            date = Time.new(2017, 10, 30, 10, 23, 45, '+09:00').utc
            allow(Time).to receive(:now).and_return(date)
          end
          it 'displays the expiration date and the remaining days' do
            cookie = YAML.safe_load(
              File.read('fastlane/spec/fixtures/actions/cookie'),
              [HTTP::Cookie, Time],
              [],
              true
            )

            expect(FastlaneCore::UI).to receive(:important).with("Your session cookie will expire at #{expect_date} (3 days left).")
            Fastlane::Actions::VerifyTwoStepSessionAction.check_expiration_time(cookie)
          end
        end

        # create: 2017-10-03 13:14:27 +09:00
        # expire: 2017-11-02 13:14:27 +09:00
        # now   : 2017-11-02 10:23:45 +09:00
        context 'when the expiration date is today' do
          before do
            date = Time.new(2017, 11, 2, 10, 23, 45, '+09:00').utc
            allow(Time).to receive(:now).and_return(date)
          end
          it 'displays the expiration date, the remaining hour and the warning message.' do
            cookie = YAML.safe_load(
              File.read('fastlane/spec/fixtures/actions/cookie'),
              [HTTP::Cookie, Time],
              [],
              true
            )

            expect(FastlaneCore::UI).to receive(:important).with("Your session cookie will expire at #{expect_date} (2 hours left).")
            expect(FastlaneCore::UI).to receive(:error).with("Your session cookie is due to expire today!")
            Fastlane::Actions::VerifyTwoStepSessionAction.check_expiration_time(cookie)
          end
        end
      end
    end
  end
end
