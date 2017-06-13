describe FastlaneCore::CrashReportGenerator do
  context 'generate crash report' do
    let(:mock_exception) do
      double(
        'Exception',
        backtrace: [
          'path/to/fastlane/line/that/crashed',
          'path/to/fastlane/line/that/called/the/crash'
        ],
        message: 'message goes here',
        fastlane_crash_came_from_plugin?: false
      )
    end

    let(:expected_body) do
      {
        'eventTime' => '0000-01-01T00:00:00+00:00',
        'serviceContext' => {
          'service' => 'fastlane',
          'version' => Fastlane::VERSION
          },
        'message' => ""
      }
    end

    before do
      allow(Time).to receive(:now).and_return(Time.utc(0))
    end

    it 'omits a message for type user_error' do
      begin
        UI.user_error!('Some User Error')
      rescue => e
        setup_sanitizer_expectation(exception: e)
        setup_expected_body(message_text: "[USER_ERROR]: ", exception: e)
        expect(FastlaneCore::CrashReportGenerator.generate(exception: e)).to eq(expected_body.to_json)
      end
    end

    it 'includes a message for other types' do
      setup_sanitizer_expectation(exception: mock_exception)
      setup_expected_body(message_text: "[EXCEPTION]: #{mock_exception.class.name}: #{mock_exception.message}\n", exception: mock_exception)
      expect(FastlaneCore::CrashReportGenerator.generate(exception: mock_exception)).to eq(expected_body.to_json)
    end

    it 'includes stack frames in message' do
      setup_sanitizer_expectation(exception: mock_exception)
      setup_expected_body(message_text: "[EXCEPTION]: #{mock_exception.message}\n", exception: mock_exception)
      report = JSON.parse(FastlaneCore::CrashReportGenerator.generate(exception: mock_exception))
      expect(report['message']).to include(mock_exception.backtrace.join("\n"))
    end

    it 'has a PLUGIN_CRASH prefix' do
      plugin_exception = FastlaneCore::Interface::FastlaneError.new
      plugin_exception.set_backtrace(['[gem_home]/gems/fastlane-plugin-appicon-0.6.0/lib/fastlane/plugin/appicon/actions/android_appicon_action.rb:23:in `run'])
      setup_expected_body(message_text: "[PLUGIN_CRASH]: #{plugin_exception.class.name}\n", exception: plugin_exception)
      expect(FastlaneCore::CrashReportGenerator.generate(exception: plugin_exception)).to eq(expected_body.to_json)
    end
  end
end

def setup_sanitizer_expectation(exception: nil)
  exception ||= mock_exception
  stack = exception.respond_to?(:trimmed_backtrace) ? exception.trimmed_backtrace : exception.backtrace
  message = exception.respond_to?(:crash_report_message) ? exception.crash_report_message : exception.message
  expect(FastlaneCore::CrashReportSanitizer).to receive(:sanitize_backtrace).with(
    backtrace: stack
  ) do |args|
    args[:backtrace]
  end
  expect(FastlaneCore::CrashReportSanitizer).to receive(:sanitize_string).with(
    string: message
  ) do |args|
    args[:string]
  end
end

def setup_expected_body(message_text: "", exception: nil)
  stack = exception.respond_to?(:trimmed_backtrace) ? exception.trimmed_backtrace : exception.backtrace
  expected_body['message'] = "#{message_text}#{stack.join("\n")}"
end
