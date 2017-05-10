describe FastlaneCore::CrashReporter do
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

    let(:stub_body) do
      {
        'key' => 'value'
      }
    end

    # let(:generator) { double('CrashReportGenerator', generate: { 'key': 'value' }) }

    before do
      allow(Time).to receive(:now).and_return(Time.new(0))
    end

    context 'post reports to Stackdriver' do
      before do
        silence_ui_output
        supress_file_writing
      end

      it 'posts a report to Stackdriver without specified type' do
        stub_stackdriver_request
        setup_crash_report_generator_expectation
        FastlaneCore::CrashReporter.report_crash(exception: exception)
      end

      it 'posts a report to Stackdriver with specified type' do
        stub_stackdriver_request(type: :crash)
        setup_crash_report_generator_expectation(type: :crash)
        FastlaneCore::CrashReporter.report_crash(type: :crash, exception: exception)
      end
    end

    context 'write report to file' do
      before do
        silence_ui_output
        supress_stackdriver_reporting
        setup_crash_report_generator_expectation
      end

      it 'writes a file with the json payload' do
        file = double('File')
        expect(File).to receive(:open).with("#{FastlaneCore.fastlane_user_dir}/last_crash.json", 'w').and_yield(file)
        expect(file).to receive(:write).with(stub_body.to_json)

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
  stub_stackdriver_request
end

def setup_crash_report_generator_expectation(type: :unknown)
  expect(FastlaneCore::CrashReportGenerator).to receive(:generate).with(
    type: type,
    exception: exception
    ).and_return(stub_body.to_json)
end

def stub_stackdriver_request(type: :unknown)
  stub_request(:post, /https:\/\/clouderrorreporting.googleapis.com\/v1beta1\/projects\/fastlane-166414\/events:report\?key=.*/).with do |request|
    request.body == stub_body.to_json
  end
end
