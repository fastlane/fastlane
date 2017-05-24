describe FastlaneCore::CrashReportSanitizer do
  context 'path sanitization' do
    let(:fastlane_spec) { double('Gem::Specification') }

    it 'returns a trace with fastlane path sanitized' do
      expect(Gem).to receive(:loaded_specs).and_return({
        'fastlane' => fastlane_spec
      })
      expect(fastlane_spec).to receive(:full_gem_path).at_least(1).and_return('/path/to/fastlane')
      expect(FastlaneCore::CrashReportSanitizer.sanitize_backtrace(
               backtrace: ['/path/to/fastlane/source/file']
      )).to eq(['[fastlane_path]/source/file'])
    end

    it 'returns a trace with gem home sanitized' do
      expect(Gem).to receive(:dir).at_least(1).and_return('/path/to/gem')
      expect(FastlaneCore::CrashReportSanitizer.sanitize_backtrace(
               backtrace: ['/path/to/gem/source/file']
      )).to eq(['[gem_home]/source/file'])
    end

    it 'returns a trace with home directory sanitized' do
      expect(Dir).to receive(:home).at_least(1).and_return('/path/to/home_dir')
      expect(FastlaneCore::CrashReportSanitizer.sanitize_backtrace(
               backtrace: ['/path/to/home_dir/source/file']
      )).to eq(['~/source/file'])
    end
  end

  context 'message sanitization' do
    let(:fastlane_spec) { double('Gem::Specification') }

    it 'returns a message with fastlane path sanitized' do
      expect(Gem).to receive(:loaded_specs).and_return({
        'fastlane' => fastlane_spec
      })
      expect(fastlane_spec).to receive(:full_gem_path).at_least(1).and_return('/path/to/fastlane')
      expect(FastlaneCore::CrashReportSanitizer.sanitize_string(
               string: '/path/to/fastlane/source/file'
      )).to eq('[fastlane_path]/source/file')
    end

    it 'returns a message with gem home sanitized' do
      expect(Gem).to receive(:dir).at_least(1).and_return('/path/to/gem')
      expect(FastlaneCore::CrashReportSanitizer.sanitize_string(
               string: '/path/to/gem/source/file'
      )).to eq('[gem_home]/source/file')
    end

    it 'returns a message with home directory sanitized' do
      expect(Dir).to receive(:home).at_least(1).and_return('/path/to/home_dir')
      expect(FastlaneCore::CrashReportSanitizer.sanitize_string(
               string: '/path/to/home_dir/source/file'
      )).to eq('~/source/file')
    end
  end
end
