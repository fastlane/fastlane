describe FastlaneCore::CrashReportGenerator do
  context 'generate crash report' do
    let(:exception) do
      double(
        'Exception',
        backtrace: [
          'path/to/fastlane/line/that/crashed',
          'path/to/fastlane/line/that/called/the/crash'
        ],
        message: 'message goes here'
      )
    end

    let(:expected_body) do
      {
        'eventTime' => '0000-01-01T00:00:00+00:00',
        'serviceContext' => {
          'service' => 'fastlane',
          'version' => '2.29.0'
          },
        'message' => ""
      }
    end

    before do
      allow(Time).to receive(:now).and_return(Time.utc(0))
    end

    it 'omits a message for type user_error' do
      setup_sanitizer_expectation(type: :user_error)
      setup_expected_body(type: :user_error, message_text: ": ")
      expect(FastlaneCore::CrashReportGenerator.generate(type: :user_error, exception: exception)).to eq(expected_body.to_json)
    end

    it 'includes a message for other types' do
      setup_sanitizer_expectation
      setup_expected_body(message_text: ": #{exception.message}\n")
      expect(FastlaneCore::CrashReportGenerator.generate(exception: exception)).to eq(expected_body.to_json)
    end

    it 'includes stack frames in message' do
      setup_sanitizer_expectation
      setup_expected_body(message_text: ": #{exception.message}\n")
      report = JSON.parse(FastlaneCore::CrashReportGenerator.generate(exception: exception))
      expect(report['message']).to include(exception.backtrace.join("\n"))
    end
  end
end

def setup_sanitizer_expectation(type: :unknown)
  expect(FastlaneCore::BacktraceSanitizer).to receive(:sanitize).with(
    type: type,
    backtrace: exception.backtrace
  ) do |args|
    args[:backtrace]
  end
end

def setup_expected_body(type: :unknown, message_text: "")
  expected_body['message'] = "#{FastlaneCore::CrashReportGenerator.types[type]}#{message_text}#{exception.backtrace.join("\n")}"
end
