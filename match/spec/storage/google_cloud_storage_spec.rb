describe Match::Storage::GoogleCloudStorage do
  describe '#download' do
    # Skips initialize, which logs in to Google Cloud.
    subject { described_class.allocate }
    let(:bucket) { double('Google::Cloud::Storage::Bucket', files: files) }

    def remote_file(name)
      double('Google::Cloud::Storage::File', name: name).tap do |file|
        allow(file).to receive(:download) { |path| File.write(path, name) }
      end
    end

    around do |example|
      Dir.mktmpdir do |dir|
        @parent = dir
        @working_directory = File.join(dir, 'wd')
        Dir.mkdir(@working_directory)
        example.run
      end
    end

    before do
      allow(Dir).to receive(:mktmpdir).and_return(@working_directory)
      allow(subject).to receive(:bucket).and_return(bucket)
    end

    context 'with names inside the working directory' do
      let(:files) { [remote_file('TEAMID/certs/distribution/CERTID.p12')] }

      it 'downloads them there' do
        subject.download

        expect(File.read(File.join(@working_directory, 'TEAMID/certs/distribution/CERTID.p12'))).to eq('TEAMID/certs/distribution/CERTID.p12')
      end
    end

    context 'with a name that resolves outside the working directory' do
      let(:files) { [remote_file('TEAMID/../../outside.p12')] }

      it 'fails without writing it' do
        expect { subject.download }.to raise_error(FastlaneCore::Interface::FastlaneError, /Refusing to download/)
        expect(File.exist?(File.join(@parent, 'outside.p12'))).to be(false)
      end
    end
  end
end
