describe Fastlane::CrashlyticsBetaInfoCollector do
  describe 'collect info into CrashlyticsBetaInfo' do
    let(:project_parser) { double('fake_project_parser') }
    let(:email_fetcher) { double('fake_email_fetcher') }
    let(:ui) { double('fake_ui') }
    let(:collector) { Fastlane::CrashlyticsBetaInfoCollector.new(project_parser, email_fetcher, ui) }
    let(:info) { Fastlane::CrashlyticsBetaInfo.new }

    let(:valid_api_key) { '0123456789012345678901234567890123456789' }
    let(:valid_build_secret) { '0123456789012345678901234567890123456789012345678901234567890123' }
    let(:valid_crashlytics_path) { './fastlane/spec/fixtures/xcodeproj/Crashlytics.framework' }
    let(:valid_emails) { ['email@domain.com'] }
    let(:valid_groups) { ['group1', 'group2'] }
    let(:valid_schemes) { ['SchemeName'] }
    let(:valid_export_method) { 'development' }
    let(:valid_project_parser_result) do
      {
        api_key: valid_api_key,
        build_secret: valid_build_secret,
        crashlytics_path: valid_crashlytics_path,
        schemes: valid_schemes
      }
    end

    before(:each) do
      allow(ui).to receive(:message)

      info.api_key = valid_api_key
      info.build_secret = valid_build_secret
      info.crashlytics_path = valid_crashlytics_path
      info.emails = valid_emails
      info.groups = valid_groups
      info.schemes = valid_schemes
      info.export_method = valid_export_method
    end

    def validate_info(expected_emails: valid_emails, expected_groups: valid_groups)
      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
      expect(info.crashlytics_path).to eq(valid_crashlytics_path)
      expect(info.emails).to eq(expected_emails)
      expect(info.groups).to eq(expected_groups)
      expect(info.schemes).to eq(valid_schemes)
      expect(info.export_method).to eq(valid_export_method)
    end

    it 'does not parse or prompt with valid api_key and build_secret and crashlytics_path' do
      expect(info).not_to(receive(:api_key=))
      expect(info).not_to(receive(:build_secret=))
      expect(info).not_to(receive(:crashlytics_path=))
      expect(info).not_to(receive(:emails=))
      expect(info).not_to(receive(:groups=))
      expect(info).not_to(receive(:schemes=))
      expect(info).not_to(receive(:export_method=))

      expect(ui).not_to(receive(:input))

      collector.collect_info_into(info)

      validate_info
    end

    it 'parses project with invalid api_key provided and does not need to prompt the user' do
      expect(project_parser).to receive(:parse).and_return(valid_project_parser_result)

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = 'invalid'

      expect(info).to receive(:api_key=).and_call_original
      expect(info).not_to(receive(:build_secret=))
      expect(info).not_to(receive(:crashlytics_path=))
      expect(info).not_to(receive(:emails=))
      expect(info).not_to(receive(:groups=))
      expect(info).not_to(receive(:schemes=))

      expect(ui).not_to(receive(:input))

      collector.collect_info_into(info)

      validate_info
    end

    it 'parses project with invalid build_secret provided' do
      expect(project_parser).to receive(:parse).and_return(valid_project_parser_result)

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.build_secret = 'invalid'

      expect(info).to receive(:build_secret=).and_call_original
      expect(info).not_to(receive(:api_key=))
      expect(info).not_to(receive(:crashlytics_path=))
      expect(info).not_to(receive(:emails=))
      expect(info).not_to(receive(:groups=))
      expect(info).not_to(receive(:schemes=))

      expect(ui).not_to(receive(:input))

      collector.collect_info_into(info)

      validate_info
    end

    it 'parses project with invalid crashlytics_path provided' do
      expect(project_parser).to receive(:parse).and_return(valid_project_parser_result)

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.crashlytics_path = 'invalid_crashlytics_path'

      expect(info).to receive(:crashlytics_path=).and_call_original
      expect(info).not_to(receive(:api_key=))
      expect(info).not_to(receive(:build_secret=))
      expect(info).not_to(receive(:emails=))
      expect(info).not_to(receive(:groups=))
      expect(info).not_to(receive(:schemes=))

      expect(ui).not_to(receive(:input))

      collector.collect_info_into(info)

      validate_info
    end

    it 'fetches email with invalid emails provided' do
      allow(project_parser).to receive(:parse).and_return(valid_project_parser_result)

      expect(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.emails = nil

      expect(info).not_to(receive(:crashlytics_path=))
      expect(info).not_to(receive(:api_key=))
      expect(info).not_to(receive(:build_secret=))
      expect(info).to receive(:emails=).and_call_original
      expect(info).not_to(receive(:groups=))
      expect(info).not_to(receive(:schemes=))

      allow(ui).to receive(:important)
      expect(ui).not_to(receive(:input))

      collector.collect_info_into(info)

      validate_info
    end

    it 'prompts for user input with invalid values provided and a project parsed with no values' do
      expect(project_parser).to receive(:parse).and_return(nil)

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.api_key = 'invalid'

      allow(ui).to receive(:important)
      expect(ui).to receive(:input).with(/API Key/).and_return(valid_api_key)

      collector.collect_info_into(info)

      validate_info
    end

    it 'prompts for user input with invalid build_secret provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.build_secret = 'invalid'

      allow(ui).to receive(:important)
      expect(ui).to receive(:important).with("your error message here")
      expect(ui).to receive(:input).with(/Build Secret/).and_return(valid_build_secret)

      collector.collect_info_into(info)

      validate_info
    end

    it 'prompts for user input with invalid crashlytics_path provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.crashlytics_path = 'invalid_crashlytics_path'

      allow(ui).to receive(:important)
      expect(ui).to receive(:important).with("your error message here")
      expect(ui).to receive(:input).with(/Crashlytics.framework/).and_return(valid_crashlytics_path)

      collector.collect_info_into(info)

      validate_info
    end

    it 'continues to prompt for user input with invalid build_secret provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.build_secret = 'invalid'

      allow(ui).to receive(:important)
      expect(ui).to receive(:important).with("your error message here")
      expect(ui).to receive(:input).with(/Build Secret/).and_return('still not valid')
      expect(ui).to receive(:input).with(/Build Secret/).and_return(valid_build_secret)

      collector.collect_info_into(info)

      validate_info
    end

    it 'prompts for user input with invalid emails and no groups provided' do
      allow(project_parser).to receive(:parse).and_return(valid_project_parser_result)

      expect(email_fetcher).to receive(:fetch).and_return(nil)

      info.emails = nil
      info.groups = nil

      allow(ui).to receive(:important)
      expect(ui).to receive(:input).with(/email/).and_return(valid_emails.first)

      collector.collect_info_into(info)

      validate_info(expected_groups: nil)
    end

    it 'does not prompt for user input with groups and invalid emails provided' do
      allow(project_parser).to receive(:parse).and_return(valid_project_parser_result)

      expect(email_fetcher).to receive(:fetch).and_return(nil)

      info.emails = nil

      expect(ui).not_to(receive(:input))

      collector.collect_info_into(info)

      validate_info(expected_emails: nil)
    end

    it 'continues to prompt for user input with invalid emails provided' do
      allow(project_parser).to receive(:parse).and_return(valid_project_parser_result)

      expect(email_fetcher).to receive(:fetch).and_return(nil)

      info.emails = nil
      info.groups = nil

      allow(ui).to receive(:important)
      expect(ui).to receive(:input).with(/email/).and_return('')
      expect(ui).to receive(:input).with(/email/).and_return(valid_emails.first)

      collector.collect_info_into(info)

      validate_info(expected_groups: nil)
    end

    it 'has the user choose from a list when there are multiple schemes' do
      schemes = ['SchemeName', 'second_scheme']
      parse_results = valid_project_parser_result.merge({ schemes: schemes })
      allow(project_parser).to receive(:parse).and_return(parse_results)
      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.schemes = schemes

      allow(ui).to receive(:important)
      expect(ui).to receive(:choose).with(/scheme/, schemes).and_return('SchemeName')

      collector.collect_info_into(info)

      validate_info
    end

    it 'prompts the user for a scheme name when none are known' do
      parse_results = valid_project_parser_result.merge({ schemes: [] })
      allow(project_parser).to receive(:parse).and_return(parse_results)
      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.schemes = []

      allow(ui).to receive(:important)
      expect(ui).to receive(:input).with(/scheme/).and_return('SchemeName')

      collector.collect_info_into(info)

      validate_info
    end

    it 'continues to prompt the user for a scheme name when an invalid one is given' do
      parse_results = valid_project_parser_result.merge({ schemes: [] })
      allow(project_parser).to receive(:parse).and_return(parse_results)
      allow(email_fetcher).to receive(:fetch).and_return(valid_emails.first)

      info.schemes = []

      allow(ui).to receive(:important)
      expect(ui).to receive(:input).with(/scheme/).and_return('')
      expect(ui).to receive(:input).with(/scheme/).and_return('SchemeName')

      collector.collect_info_into(info)

      validate_info
    end

    it 'does not prompt the user when a valid export method is provided' do
      expect(info).not_to(receive(:api_key=))
      expect(info).not_to(receive(:build_secret=))
      expect(info).not_to(receive(:crashlytics_path=))
      expect(info).not_to(receive(:emails=))
      expect(info).not_to(receive(:groups=))
      expect(info).not_to(receive(:schemes=))
      expect(info).not_to(receive(:export_method=))

      expect(ui).not_to(receive(:choose))

      collector.collect_info_into(info)

      validate_info
    end

    it 'prompts the user to choose a export method when an invalid one is provided' do
      info.export_method = 'rando'

      allow(ui).to receive(:important)
      expect(ui).to receive(:choose).with(/export method/, Fastlane::CrashlyticsBetaInfo::EXPORT_METHODS).and_return(valid_export_method)

      collector.collect_info_into(info)

      validate_info
    end

    it 'has a default value of development for export method when none is provided' do
      info.export_method = nil

      expect(ui).not_to(receive(:choose))

      collector.collect_info_into(info)

      validate_info
    end
  end
end
