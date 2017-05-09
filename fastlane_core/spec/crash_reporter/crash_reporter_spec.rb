# require 'webmock/rspec'

describe FastlaneCore::CrashReporter do
  STACKDRIVER_URL = 'https://clouderrorreporting.googleapis.com/v1beta1/projects/fastlane-166414/events:report?key=stackdriver_api_key'
  ENV['STACKDRIVER_API_KEY'] = "stackdriver_api_key"
  context 'crash reporting' do
    let(:exception) do
      double(
        'Exception',
        backtrace: [
          'path/to/fastlane/line/that/crashed',
          'path/to/fastlane/line/that/called/the/crash'
        ]
      )
    end

    let(:expected_body) do
      {
        'eventTime': '0000-01-01T00:00:00-05:00',
        'serviceContext': {
          'service': 'fastlane',
          'version': '2.29.0'
          },
        'message': ""
      }
    end

    before do
      allow(Time).to receive(:now).and_return(Time.new(0))
    end

    it 'posts a report to Stackdriver' do
      setup_sanitizer_expectation
      stub_stackdriver_request
      FastlaneCore::CrashReporter.report_crash(exception: exception)
    end

    it 'posts a report of specified type to Stackdriver' do
      setup_sanitizer_expectation(type: :crash)
      stub_stackdriver_request(type: :crash)
      FastlaneCore::CrashReporter.report_crash(type: :crash, exception: exception)
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

def stub_stackdriver_request(type: :unknown)
  expected_body[:message] = "#{FastlaneCore::CrashReporter.types[type]}: #{exception.backtrace.join("\n")}"
  stub_request(:post, STACKDRIVER_URL).with do |request|
    request.body == expected_body.to_json
  end
end
