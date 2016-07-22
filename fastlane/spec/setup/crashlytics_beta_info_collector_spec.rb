describe Fastlane::CrashlyticsBetaInfoCollector do
  describe 'collect info into CrashlyticsBetaInfo' do
    let(:project_parser) { double('fake_project_parser') }
    let(:email_fetcher) { double('fake_email_fetcher') }
    let(:collector) { Fastlane::CrashlyticsBetaInfoCollector.new(project_parser, email_fetcher) }
    let(:info) { Fastlane::CrashlyticsBetaInfo.new }

    let(:valid_api_key) { '0123456789012345678901234567890123456789' }
    let(:valid_build_secret) { '0123456789012345678901234567890123456789012345678901234567890123' }
    let(:valid_crashlytics_path) { 'spec/fixtures/xcodeproj/Crashlytics.framework' }
    let(:valid_emails) { ['email@domain.com'] }

    it 'does not parse or prompt with valid api_key and build_secret and crashlytics_path' do
      info.api_key = valid_api_key
      info.build_secret = valid_build_secret
      info.crashlytics_path = valid_crashlytics_path
      info.emails = valid_emails

      expect(info).not_to receive(:api_key=)
      expect(info).not_to receive(:build_secret=)
      expect(info).not_to receive(:crashlytics_path=)
      expect(info).not_to receive(:emails=)

      expect(UI).not_to receive(:ask)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'parses project with invalid api_key provided and does not need to prompt the user' do
      expect(project_parser).to receive(:parse).and_return({ api_key: valid_api_key, build_secret: valid_build_secret, crashlytics_path: valid_crashlytics_path })

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = 'invalid'
      info.build_secret = valid_build_secret
      info.crashlytics_path = valid_crashlytics_path
      info.emails = valid_emails

      expect(info).to receive(:api_key=).and_call_original
      expect(info).not_to receive(:build_secret=)
      expect(info).not_to receive(:crashlytics_path=)
      expect(info).not_to receive(:emails=)

      expect(UI).not_to receive(:ask)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'parses project with invalid build_secret provided' do
      expect(project_parser).to receive(:parse).and_return({ api_key: valid_api_key, build_secret: valid_build_secret, crashlytics_path: valid_crashlytics_path })

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = valid_api_key
      info.build_secret = 'invalid'
      info.crashlytics_path = valid_crashlytics_path
      info.emails = valid_emails

      expect(info).to receive(:build_secret=).and_call_original
      expect(info).not_to receive(:api_key=)
      expect(info).not_to receive(:crashlytics_path=)
      expect(info).not_to receive(:emails=)

      expect(UI).not_to receive(:ask)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'parses project with invalid crashlytics_path provided' do
      expect(project_parser).to receive(:parse).and_return({ api_key: valid_api_key, build_secret: valid_build_secret, crashlytics_path: valid_crashlytics_path })

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = valid_api_key
      info.build_secret = valid_build_secret
      info.crashlytics_path = 'invalid_crashlytics_path'
      info.emails = valid_emails

      expect(info).to receive(:crashlytics_path=).and_call_original
      expect(info).not_to receive(:api_key=)
      expect(info).not_to receive(:build_secret=)
      expect(info).not_to receive(:emails=)

      expect(UI).not_to receive(:ask)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'fetches email with invalid emails provided' do
      allow(project_parser).to receive(:parse).and_return({ api_key: valid_api_key, build_secret: valid_build_secret, crashlytics_path: valid_crashlytics_path })

      expect(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = valid_api_key
      info.build_secret = valid_build_secret
      info.crashlytics_path = valid_crashlytics_path
      info.emails = nil

      expect(info).not_to receive(:crashlytics_path=)
      expect(info).not_to receive(:api_key=)
      expect(info).not_to receive(:build_secret=)
      expect(info).to receive(:emails=).and_call_original

      expect(UI).not_to receive(:ask)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'prompts for user input with invalid values provided and a project parsed with no values' do
      expect(project_parser).to receive(:parse).and_return(nil)

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = 'invalid'
      info.build_secret = valid_build_secret
      info.crashlytics_path = valid_crashlytics_path
      info.emails = valid_emails

      expect(UI).to receive(:ask).with(/API Key/).and_return(valid_api_key)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'prompts for user input with invalid build_secret provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = valid_api_key
      info.build_secret = 'invalid'
      info.crashlytics_path = valid_crashlytics_path
      info.emails = valid_emails

      allow(UI).to receive(:important)
      expect(UI).to receive(:important).with("your error message here")
      expect(UI).to receive(:ask).with(/Build Secret/).and_return(valid_build_secret)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'prompts for user input with invalid crashlytics_path provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = valid_api_key
      info.build_secret = valid_build_secret
      info.crashlytics_path = 'invalid_crashlytics_path'
      info.emails = valid_emails

      allow(UI).to receive(:important)
      expect(UI).to receive(:important).with("your error message here")
      expect(UI).to receive(:ask).with(/Crashlytics.framework/).and_return(valid_crashlytics_path)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'continues to prompt for user input with invalid build_secret provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = valid_api_key
      info.build_secret = 'invalid'
      info.crashlytics_path = valid_crashlytics_path
      info.emails = valid_emails

      allow(UI).to receive(:important)
      expect(UI).to receive(:important).with("your error message here")
      expect(UI).to receive(:ask).with(/Build Secret/).and_return('still not valid')
      expect(UI).to receive(:ask).with(/Build Secret/).and_return(valid_build_secret)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'prompts for user input with invalid emails provided' do
      allow(project_parser).to receive(:parse).and_return({ api_key: valid_api_key, build_secret: valid_build_secret, crashlytics_path: valid_crashlytics_path })

      expect(email_fetcher).to receive(:fetch).and_return(nil)

      info.api_key = valid_api_key
      info.build_secret = valid_build_secret
      info.crashlytics_path = valid_crashlytics_path
      info.emails = nil

      expect(UI).to receive(:ask).with(/email/).and_return(valid_emails.first)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end

    it 'continues to prompt for user input with invalid emails provided' do
      allow(project_parser).to receive(:parse).and_return({ api_key: valid_api_key, build_secret: valid_build_secret, crashlytics_path: valid_crashlytics_path })

      expect(email_fetcher).to receive(:fetch).and_return(nil)

      info.api_key = valid_api_key
      info.build_secret = valid_build_secret
      info.crashlytics_path = valid_crashlytics_path
      info.emails = nil

      expect(UI).to receive(:ask).with(/email/).and_return('')
      expect(UI).to receive(:ask).with(/email/).and_return(valid_emails.first)

      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(valid_emails)
    end
  end
end
