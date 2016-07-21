describe Fastlane::CrashlyticsBetaInfoCollector do
  describe 'collect info into CrashlyticsBetaInfo' do
    let(:project_parser) { double('fake_project_parser') }
    let(:valid_api_key) { '0123456789012345678901234567890123456789' }
    let(:valid_build_secret) { '0123456789012345678901234567890123456789012345678901234567890123' }

    it 'does not parse or prompt with valid api_key and build_secret' do
      info = Fastlane::CrashlyticsBetaInfo.new
      info.api_key = valid_api_key
      info.build_secret = valid_build_secret

      expect(info).not_to receive(:api_key=)
      expect(info).not_to receive(:build_secret=)

      expect(UI).not_to receive(:ask)

      collector = Fastlane::CrashlyticsBetaInfoCollector.new(project_parser)
      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
    end

    it 'parses project with invalid api_key provided and does not need to prompt the user' do
      expect(project_parser).to receive(:parse).and_return({api_key: valid_api_key, build_secret: valid_build_secret})

      info = Fastlane::CrashlyticsBetaInfo.new
      info.api_key = 'invalid'
      info.build_secret = valid_build_secret

      expect(info).to receive(:api_key=).and_call_original
      expect(info).not_to receive(:build_secret=)

      expect(UI).not_to receive(:ask)

      collector = Fastlane::CrashlyticsBetaInfoCollector.new(project_parser)
      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
    end

    it 'parses project with invalid build_secret provided' do
      expect(project_parser).to receive(:parse).and_return({api_key: valid_api_key, build_secret: valid_build_secret})

      info = Fastlane::CrashlyticsBetaInfo.new
      info.api_key = valid_api_key
      info.build_secret = 'invalid'

      expect(info).to receive(:build_secret=).and_call_original
      expect(info).not_to receive(:api_key=)

      expect(UI).not_to receive(:ask)

      collector = Fastlane::CrashlyticsBetaInfoCollector.new(project_parser)
      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
    end

    it 'prompts for user input with invalid values provided and a project parsed with no values' do
      expect(project_parser).to receive(:parse).and_return(nil)

      info = Fastlane::CrashlyticsBetaInfo.new
      info.api_key = 'invalid'
      info.build_secret = valid_build_secret

      expect(UI).to receive(:ask).with(/API Key/).and_return(valid_api_key)

      collector = Fastlane::CrashlyticsBetaInfoCollector.new(project_parser)
      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
    end

    it 'prompts for user input with invalid build_secret provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      info = Fastlane::CrashlyticsBetaInfo.new
      info.api_key = valid_api_key
      info.build_secret = 'invalid'

      expect(UI).to receive(:important).with("your error message here")
      expect(UI).to receive(:ask).with(/Build Secret/).and_return(valid_build_secret)

      collector = Fastlane::CrashlyticsBetaInfoCollector.new(project_parser)
      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
    end

    it 'continues to prompt for user input with invalid build_secret provided and with an error in project parsing' do
      expect(project_parser).to receive(:parse).and_raise("your error message here")

      info = Fastlane::CrashlyticsBetaInfo.new
      info.api_key = valid_api_key
      info.build_secret = 'invalid'

      expect(UI).to receive(:important).with("your error message here")
      expect(UI).to receive(:ask).with(/Build Secret/).and_return('still not valid')
      expect(UI).to receive(:ask).with(/Build Secret/).and_return(valid_build_secret)

      collector = Fastlane::CrashlyticsBetaInfoCollector.new(project_parser)
      collector.collect_info_into(info)

      expect(info.api_key).to eq(valid_api_key)
      expect(info.build_secret).to eq(valid_build_secret)
    end
  end
end
