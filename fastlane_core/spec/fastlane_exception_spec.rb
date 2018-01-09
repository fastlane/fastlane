describe FastlaneCore::Interface::FastlaneException do
  context 'raising fastlane exceptions' do
    it 'properly determines that it was called via `UI.user_error!`' do
      begin
        UI.user_error!('USER ERROR!!')
      rescue => e
        expect(e.caused_by_calling_ui_method?(method_name: 'user_error!')).to be(true)
      end
    end

    it 'properly determines that it was called via `UI.crash!`' do
      begin
        UI.crash!('CRASH!!')
      rescue => e
        expect(e.caused_by_calling_ui_method?(method_name: 'crash!')).to be(true)
      end
    end

    it 'properly determines that the exception was raised explicitly' do
      begin
        raise FastlaneCore::Interface::FastlaneError.new, 'EXPLICITLY RAISED ERROR'
      rescue => e
        expect(e.caused_by_calling_ui_method?(method_name: 'user_error!')). to be(false)
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

    it 'does not trim two frames if method_missing not included' do
      mock_backtrace = ["/path/to/interface.rb:1234:in `user_error!'", "path/to/caller.rb:10: in `hello!'", "path/to/another/file.rb:1337"]
      exception = FastlaneCore::Interface::FastlaneError.new
      expect(exception).to receive(:backtrace).at_least(:once).and_return(mock_backtrace)
      expect(exception.trimmed_backtrace.count).to eq(exception.backtrace.count - 1)
    end

    it 'does trim two frames if method_messing included' do
      mock_backtrace = ["/path/to/interface.rb:1234:in `user_error!'", "path/to/ui.rb:10: in `method_missing'", "path/to/caller:10: in `hello!'", "path/to/another/file.rb:1337"]
      exception = FastlaneCore::Interface::FastlaneError.new
      expect(exception).to receive(:backtrace).at_least(:once).and_return(mock_backtrace)
      expect(exception.trimmed_backtrace.count).to eq(exception.backtrace.count - 2)
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

  context 'shell error stack trimming' do
    # testing the shell error stack trimming behavior is complicated, because
    # the code explicitly only removes frames in sh_helper.rb, but we cannot
    # actually have those frames in a backtrace in a unit test
    # so, we will stub the backtrace on the object under test to return a
    # hard code backtrace, and be sure that is trimmed properly
    it 'trims backtrace containing sh_helper.rb' do
      mock_backtrace = ["path/to/sh_helper.rb:55", "path/to/sh_helper.rb:10", "path/to/another/file.rb:1337"]
      exception = FastlaneCore::Interface::FastlaneShellError.new("SHELL ERROR!!")
      expect(exception).to receive(:backtrace).at_least(:once).and_return(mock_backtrace)
      expect(exception.trimmed_backtrace).to eq(mock_backtrace.drop(2))
    end

    it 'does not trim backtrace not containing sh_helper.rb' do
      mock_backtrace = ["path/to/file.rb:1337", "path/to/file.rb:2001"]
      exception = FastlaneCore::Interface::FastlaneShellError.new("SHELL ERROR!!")
      expect(exception).to receive(:backtrace).at_least(:once).and_return(mock_backtrace)
      expect(exception.trimmed_backtrace).to eq(mock_backtrace)
    end
  end
end
