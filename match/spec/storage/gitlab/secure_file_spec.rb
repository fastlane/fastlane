
describe Match do
  describe Match::Storage::GitLab::SecureFile do
    let(:client) {
      Match::Storage::GitLab::Client.new(
        api_v4_url: 'https://gitlab.example.com/api/v4',
        project_id: 'sample/project',
        private_token: 'abc123'
)
    }

    subject {
      described_class.new(
        file: file,
        client: client
)
    }

    describe '#file_url' do
      context 'returns the expected file_url for the given configuration' do
        let(:file) { { id: 1 } }

        it { expect(subject.file_url).to eq('https://gitlab.example.com/api/v4/projects/sample%2Fproject/secure_files/1') }
      end
    end

    describe '#destination_file_path' do
      context 'strips the leading / if supplied' do
        let(:file) { { name: '/a/b/c/myfile' } }

        it { expect(subject.destination_file_path).to eq('a/b/c/') }
      end

      context 'strips the file name from the path' do
        let(:file) { { name: 'a/b/c/myfile' } }

        it { expect(subject.destination_file_path).to eq('a/b/c/') }
      end

      context 'returns an empty string if no path is given' do
        let(:file) { { name: 'myfile' } }

        it { expect(subject.destination_file_path).to eq('') }
      end
    end

    describe '#create_subfolders' do
      context 'with a supplied sub-folder path' do
        let(:file) { { name: 'a/b/c/myfile' } }

        it 'creates the necessary sub-folders' do
          expect(FileUtils).to receive(:mkdir_p).with(Dir.pwd + '/a/b/c/')

          subject.create_subfolders(Dir.pwd)
        end
      end

      context 'with no sub-folders in the path' do
        let(:file) { { name: 'myfile' } }

        it 'does not create subfolders' do
          expect(FileUtils).to receive(:mkdir_p).with(Dir.pwd + '/')

          subject.create_subfolders(Dir.pwd)
        end
      end
    end

    describe '#valid_checksum?' do
      let(:file) { { checksum: checksum } }

      context 'when the checksum supplied matches the checksum of the file ' do
        let(:file_contents) { 'hello' }
        let(:file) { { checksum: Digest::SHA256.hexdigest(file_contents) } }

        it 'returns true' do
          tempfile = Tempfile.new
          tempfile.write(file_contents)
          tempfile.close

          expect(subject.valid_checksum?(tempfile.path)).to be true
        end
      end

      context 'when the checksum supplied does not match the checksum of the file' do
        let(:file_contents) { 'hello' }
        let(:file) { { checksum: 'foo' } }

        it 'returns false' do
          tempfile = Tempfile.new
          tempfile.write(file_contents)
          tempfile.close

          expect(subject.valid_checksum?(tempfile.path)).to be false
        end
      end
    end

    describe '#delete' do
      let(:file) { { id: 1 } }

      it 'sends the delete request to the client' do
        url = URI(subject.file_url)

        expect_any_instance_of(Match::Storage::GitLab::Client).to receive(:execute_request).with(url, anything)

        subject.delete
      end
    end
  end
end
