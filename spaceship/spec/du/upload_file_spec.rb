describe Spaceship::UploadFile do
  describe '.remove_alpha_channel' do
    let(:original) { File.join('fastlane', 'spec', 'fixtures', 'screenshots', 'screenshot1.png') }

    around do |example|
      Dir.mktmpdir("upload_file_spec-") do |dir|
        @tmpdir = dir
        FastlaneSpec::Env.with_env_values('TMPDIR' => dir) { example.run }
      end
    end

    before do
      allow(described_class).to receive(:mac?).and_return(false)
    end

    it 'copies the image into a fresh temporary directory' do
      copy = described_class.remove_alpha_channel(original)

      expect(copy).to start_with(@tmpdir)
      expect(copy).not_to eq(File.join(@tmpdir, "#{Digest::MD5.hexdigest(original)}.png"))
      expect(File.basename(copy)).to eq('screenshot1.png')
      expect(File.binread(copy)).to eq(File.binread(original))
    end
  end
end
