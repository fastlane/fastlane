describe FastlaneCore::Interface::FastlaneException do
  context 'raising fastlane exceptions' do
    it 'properly determines that it was called via `UI.user_error!`' do
      begin
        UI.user_error!('USER ERROR!!')
      rescue => e
        expect(e.caused_by_calling_ui_method?(method_name: 'user_error!')).to be true
      end
    end

    it 'properly determines that it was called via `UI.crash!`' do
      begin
        UI.crash!('CRASH!!')
      rescue => e
        expect(e.caused_by_calling_ui_method?(method_name: 'crash!')).to be true
      end
    end

    it 'properly determines that the exception was raised explicitly' do
      begin
        raise FastlaneCore::Interface::FastlaneError.new, 'EXPLICITLY RAISED ERROR'
      rescue => e
        expect(e.caused_by_calling_ui_method?(method_name: 'user_error!')). to be false
      end
    end
  end

  context 'backtrace trimming' do
    it 'trims backtrace if called via UI method' do
      begin
        UI.user_error!('USER ERROR!!')
      rescue => e
        expect(e).to respond_to(:trimmed_backtrace)
        expect(e.trimmed_backtrace.count).to eq(e.backtrace.count - 2)
      end
    end

    it 'does not trim backtrace if raised explicitly' do
      begin
        raise FastlaneCore::Interface::FastlaneError.new, 'EXPLICITLY RAISED ERROR'
      rescue => e
        expect(e).to respond_to(:trimmed_backtrace)
        expect(e.trimmed_backtrace.count).to eq(e.backtrace.count)
      end
    end
  end

  context 'crash report message' do
    it 'returns an empty string if the message could contain PII' do
      begin
        UI.user_error!('USER ERROR!!')
      rescue => e
        expect(e).to respond_to(:crash_report_message)
        expect(e.crash_report_message).to eq('')
      end
    end

    it 'returns the original exception message if the message does not contain PII' do
      begin
        raise FastlaneCore::Interface::FastlaneError.new, 'EXPLICITLY RAISED ERROR'
      rescue => e
        expect(e).to respond_to(:crash_report_message)
        expect(e.crash_report_message).to eq(e.message)
      end
    end
  end
end
