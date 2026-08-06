describe FastlaneCore do
  describe FastlaneCore::VideoUtils do
    let(:path) { File.expand_path("../fixtures/videos/#{video}.mp4", __FILE__) }

    describe '::read_video_resolution' do
      subject { described_class.read_video_resolution(path) }

      context 'when the video track is the first track' do
        let(:video) { 'video_first' }
        it { is_expected.to eq([64, 128]) }
      end

      context 'when an audio track precedes the video track' do
        let(:video) { 'audio_first' }
        it { is_expected.to eq([64, 128]) }
      end

      context 'when the file is not a valid MP4' do
        let(:path) { __FILE__ }
        it { is_expected.to be_nil }
      end

      context 'when the file does not exist' do
        let(:video) { 'missing' }
        it { is_expected.to be_nil }
      end
    end

    describe '::read_video_duration_seconds' do
      subject { described_class.read_video_duration_seconds(path) }

      context 'when the video track is the first track' do
        let(:video) { 'video_first' }
        it { is_expected.to be_within(0.2).of(1.0) }
      end

      context 'when an audio track precedes the video track' do
        let(:video) { 'audio_first' }
        it { is_expected.to be_within(0.2).of(1.0) }
      end

      context 'when the file is not a valid MP4' do
        let(:path) { __FILE__ }
        it { is_expected.to be_nil }
      end
    end
  end
end
