require 'spec_helper'

describe Commander::Runner do
  describe '#handle_unknown_error' do
    class CustomError < StandardError
      def preferred_error_info
        ['Title', 'Line 1', 'Line 2']
      end
    end

    class NilReturningError < StandardError
      def preferred_error_info
        nil
      end
    end

    before(:each) do
      allow(FastlaneCore::CrashReporting).to receive(:enabled?).and_return(false)
    end

    it 'should reraise errors that are not of special interest' do
      expect do
        Commander::Runner.new.handle_unknown_error!(StandardError.new('my message'))
      end.to raise_error(StandardError, '[!] my message'.red)
    end

    it 'should reraise errors that return nil from #preferred_error_info' do
      expect do
        Commander::Runner.new.handle_unknown_error!(NilReturningError.new('my message'))
      end.to raise_error(StandardError, '[!] my message'.red)
    end

    it 'should abort and show custom info for errors that have the Apple error info provider method with $verbose=false' do
      runner = Commander::Runner.new
      expect(runner).to receive(:abort).with("\n[!] Title\n\tLine 1\n\tLine 2".red)

      with_verbose(false) do
        runner.handle_unknown_error!(CustomError.new)
      end
    end

    it 'should reraise and show custom info for errors that have the Apple error info provider method with $verbose=true' do
      with_verbose(true) do
        expect do
          Commander::Runner.new.handle_unknown_error!(CustomError.new)
        end.to raise_error(CustomError, "[!] Title\n\tLine 1\n\tLine 2".red)
      end
    end
  end
end
