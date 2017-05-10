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
        ],
        message: 'message goes here'
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

    context 'post reports to Stackdriver' do
      before do
        silence_ui_output
        supress_file_writing
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

    context 'write report to file' do
      before do
        silence_ui_output
        supress_stackdriver_reporting
      end

      it 'writes a file with the json payload' do
        file = double('File')
        expect(File).to receive(:open).with("#{FastlaneCore.fastlane_user_dir}/last_crash.json", 'w').and_yield(file)
        expect(file).to receive(:write).with(expected_body.to_json)

        FastlaneCore::CrashReporter.report_crash(exception: exception)
      end
    end

    context 'reporting exception message' do
      before do
        silence_ui_output
        supress_file_writing
      end

      it 'omits exception message for user_error' do
        setup_sanitizer_expectation(type: :user_error)
        stub_stackdriver_request(type: :user_error)
        FastlaneCore::CrashReporter.report_crash(exception: exception)
      end

      it 'includes exception message for other crash types' do
        setup_sanitizer_expectation
        stub_stackdriver_request
        FastlaneCore::CrashReporter.report_crash(exception: exception)
      end
    end

    context 'message user about crash reporting' do
      before do
        supress_file_writing
        supress_stackdriver_reporting
      end

      it 'prints information about crash reporting' do
        expect(UI).to receive(:important).with("We logged a crash report to #{FastlaneCore::CrashReporter.crash_report_path}")
        expect(UI).to receive(:important).with("We sent a crash report to help us make _fastlane_ better!")
        FastlaneCore::CrashReporter.report_crash(exception: exception)
      end
    end
  end
end

def silence_ui_output
  allow(UI).to receive(:important)
end

def supress_file_writing
  file = double('File')
  allow(File).to receive(:open).and_yield(file)
  allow(file).to receive(:write)
end

def supress_stackdriver_reporting
  setup_sanitizer_expectation
  stub_stackdriver_request
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
  expected_body[:message] = "#{FastlaneCore::CrashReporter.types[type]} #{exception.message}: #{exception.backtrace.join("\n")}"
  stub_request(:post, STACKDRIVER_URL).with do |request|
    request.body == expected_body.to_json
  end
end
