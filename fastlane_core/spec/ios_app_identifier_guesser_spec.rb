require 'spec_helper'

require 'fastlane_core/ios_app_identifier_guesser'

describe FastlaneCore::IOSAppIdentifierGuesser do
  it 'returns nil if no clues' do
    # this might also fail if the environment or config files are not clean
    expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier([])).to be_nil
  end

  describe 'guessing from command line args' do
    it 'returns iOS app_identifier if specified with -a' do
      args = ["-a", "com.krausefx.app"]
      expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier(args)).to eq("com.krausefx.app")
    end

    it 'returns iOS app_identifier if specified with --app_identifier' do
      args = ["--app_identifier", "com.krausefx.app"]
      expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier(args)).to eq("com.krausefx.app")
    end
  end

  describe 'guessing from environment' do
    it 'returns iOS app_identifier present in environment' do
      ["FASTLANE", "DELIVER", "PILOT", "PRODUCE", "PEM", "SIGH", "SNAPSHOT", "MATCH"].each do |current|
        env_var_name = "#{current}_APP_IDENTIFIER"
        app_identifier = "#{current}.bundle.id"
        ENV[env_var_name] = app_identifier
        expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier([])).to eq(app_identifier)
        ENV.delete(env_var_name)
      end
    end
  end

  describe 'guessing from Appfile' do
    it 'returns iOS app_identifier found in Appfile' do
      expect(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).with(:app_identifier).and_return("Appfile.bundle.id")
      expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier([])).to eq("Appfile.bundle.id")
    end
  end

  describe 'guessing from configuration files' do
    def allow_non_target_configuration_file(file_name)
      allow_any_instance_of(FastlaneCore::Configuration).to receive(:load_configuration_file).with(file_name, any_args) do |configuration, config_file_name|
        nil
      end
    end

    def allow_target_configuration_file(file_name)
      allow_any_instance_of(FastlaneCore::Configuration).to receive(:load_configuration_file).with(file_name, any_args) do |configuration, config_file_name|
        configuration[:app_identifier] = "#{config_file_name}.bundle.id"
      end
    end

    it 'returns iOS app_identifier found in Deliverfile' do
      allow_target_configuration_file("Deliverfile")
      allow_non_target_configuration_file("Gymfile")
      allow_non_target_configuration_file("Matchfile")
      allow_non_target_configuration_file("Snapfile")
      expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier([])).to eq("Deliverfile.bundle.id")
    end

    it 'catches common permuations of application id with swift matcher' do
      expected_app_ids = [
        "a.c.b",
        "a.c.b",
        "a.c.b",
        "a.c.b",
        "a.c.b",
        "a.c.b",
        "a-c-b",
        "a",
        "ad",
        "a--.--.b"
      ]

      valid_id_strings = [
        "var appIdentifier: String { return \"a.c.b\" }",
        "var appIdentifier: String? { return \"a.c.b\" }",
        "var appIdentifier: String[] { return [\"a.c.b\"] }",
        "var appIdentifier: String {return \"a.c.b\"}",
        "var appIdentifier: String {return \"a.c.b\"} ",
        "var  appIdentifier:  String {  return  \"a.c.b \"  }",
        "var appIdentifier: String { return \"a-c-b\" }",
        "var appIdentifier: String { return \"a\" }",
        "var appIdentifier: String { return \"ad\" }",
        "var appIdentifier: String { return \"a--.--.b\" }"
      ]

      valid_id_strings.zip(expected_app_ids).each do |line, expected_app_id|
        app_id = FastlaneCore::IOSAppIdentifierGuesser.match_swift_application_id(text_line: line)
        expect(app_id).to eq(expected_app_id)
      end
    end

    it 'ignores non-application ids with swift matcher' do
      valid_id_strings = [
        "var appIdentifier: String { return \"\" }",
        "var appIdentifier: String",
        "var appIdentifier: String { get }",
        "var appIdentifier: String? { return nil }",
        "var appIdentifier: String? { get }",
        "var appIdentifier: String[] { return [] }",
        "var appIdentifier: String[] { get }",
        "var appIdentifier: String [ ] {get }",
        "var appId: String { return \"\" }",
        "var appId: String { get }"
      ]

      valid_id_strings.each do |line|
        expect(FastlaneCore::IOSAppIdentifierGuesser.match_swift_application_id(text_line: line)).to be_nil
      end
    end

    it 'returns iOS app_identifier found in Gymfile' do
      allow_target_configuration_file("Gymfile")
      allow_non_target_configuration_file("Deliverfile")
      allow_non_target_configuration_file("Matchfile")
      allow_non_target_configuration_file("Snapfile")
      expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier([])).to eq("Gymfile.bundle.id")
    end

    it 'returns iOS app_identifier found in Snapfile' do
      allow_target_configuration_file("Snapfile")
      allow_non_target_configuration_file("Deliverfile")
      allow_non_target_configuration_file("Gymfile")
      allow_non_target_configuration_file("Matchfile")
      expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier([])).to eq("Snapfile.bundle.id")
    end

    it 'returns iOS app_identifier found in Matchfile' do
      allow_target_configuration_file("Matchfile")
      allow_non_target_configuration_file("Deliverfile")
      allow_non_target_configuration_file("Gymfile")
      allow_non_target_configuration_file("Snapfile")
      expect(FastlaneCore::IOSAppIdentifierGuesser.guess_app_identifier([])).to eq("Matchfile.bundle.id")
    end
  end
end
