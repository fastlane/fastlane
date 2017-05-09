describe FastlaneCore::BacktraceSanitizer do
  context 'path sanitization' do
    let(:fastlane_spec) { double('Gem::Specification') }

    it 'returns a trace with fastlane path sanitized' do
      expect(Gem).to receive(:loaded_specs).and_return({
        'fastlane' => fastlane_spec
      })
      expect(fastlane_spec).to receive(:full_gem_path).at_least(1).and_return('/path/to/fastlane')
      expect(FastlaneCore::BacktraceSanitizer.sanitize(
        type: nil,
        backtrace: ['/path/to/fastlane/source/file'])
      ).to eq(['[fastlane_path]/source/file'])
    end

    it 'returns a trace with gem home sanitized' do
      expect(Gem).to receive(:dir).at_least(1).and_return('/path/to/gem')
      expect(FastlaneCore::BacktraceSanitizer.sanitize(
        type: nil,
        backtrace: ['/path/to/gem/source/file'])
      ).to eq(['[gem_home]/source/file'])
    end

    it 'returns a trace with home directory sanitized' do
      expect(Dir).to receive(:home).at_least(1).and_return('/path/to/home_dir')
      expect(FastlaneCore::BacktraceSanitizer.sanitize(
        type: nil,
        backtrace: ['/path/to/home_dir/source/file'])
      ).to eq(['~/source/file'])
    end
  end

  context 'stack frame dropping' do
    it 'drops the first two frames from crashes' do
      expect(FastlaneCore::BacktraceSanitizer.sanitize(
        type: :crash,
        backtrace: ['frame0', 'frame1', 'frame2'])
      ).to eq(['frame2'])
    end

    it 'drops the first two frames from user errors' do
      expect(FastlaneCore::BacktraceSanitizer.sanitize(
        type: :user_error,
        backtrace: ['frame0', 'frame1', 'frame2'])
      ).to eq(['frame2'])
    end

    it 'drops no frames from other errors' do
      expect(FastlaneCore::BacktraceSanitizer.sanitize(
        type: nil,
        backtrace: ['frame0', 'frame1', 'frame2'])
      ).to eq(['frame0', 'frame1', 'frame2'])
    end
  end
end