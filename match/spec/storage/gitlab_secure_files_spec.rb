describe Match do
  describe Match::Storage::GitLabSecureFiles do
    subject { described_class.new(private_token: 'abc123', project_id: 'fake-project') }
    let(:working_directory) { '/fake/path/to/files' }

    before do
      allow(subject).to receive(:working_directory).and_return(working_directory)
    end

    describe '.configure' do
      describe 'api_v4_url' do
        it 'sets the value to CI_API_V4_URL when supplied' do
          stub_const('ENV', ENV.to_hash.merge('CI_API_V4_URL' => 'https://gitlab.com/api/v4'))

          storage = described_class.configure({})

          expect(storage.api_v4_url).to eq('https://gitlab.com/api/v4')
        end

        it 'sets the value based on the gitlab_host param' do
          storage = described_class.configure(gitlab_host: 'http://gitlab.foo.com')

          expect(storage.api_v4_url).to eq('http://gitlab.foo.com/api/v4')
        end
      end
    end

    describe '#upload_files' do
      let(:files_to_upload) do
        [
          "#{working_directory}/ABCDEFG/certs/development/ABCDEFG.cer",
          "#{working_directory}/ABCDEFG/certs/development/ABCDEFG.p12"
        ]
      end

      let!(:file) { class_double('File', read: 'body').as_stubbed_const }

      it 'reads the correct files from local storage' do
        files_to_upload.each do |file_name|
          expect(file).to receive(:open).with(file_name)
        end

        subject.upload_files(files_to_upload: files_to_upload)
      end

      it 'uploads files to the correct path in remote storage' do
        expect(subject.gitlab_client).to receive(:upload_file).with("#{working_directory}/ABCDEFG/certs/development/ABCDEFG.cer", 'ABCDEFG/certs/development/ABCDEFG.cer')
        expect(subject.gitlab_client).to receive(:upload_file).with("#{working_directory}/ABCDEFG/certs/development/ABCDEFG.p12", 'ABCDEFG/certs/development/ABCDEFG.p12')
        subject.upload_files(files_to_upload: files_to_upload)
      end
    end

    describe '#delete_files' do
      let(:file_names) do
        [
          'ABCDEFG/certs/development/ABCDEFG.cer',
          'ABCDEFG/certs/development/ABCDEFG.p12'
        ]
      end

      let(:secure_files) do
        file_names.map.with_index do |file_name, index|
          Match::Storage::GitLab::SecureFile.new(file: { id: index, name: file_name }, client: subject.gitlab_client)
        end
      end

      let(:files_to_delete) do
        file_names.map do |file_name|
          "#{working_directory}/#{file_name}"
        end
      end

      it 'deletes files with correct paths' do
        secure_files.each_with_index do |secure_file, index|
          expect(subject.gitlab_client).to receive(:find_file_by_name).with(file_names[index]).and_return(secure_file)
          expect(secure_file.file.name).to eq(file_names[index])
          expect(secure_file).to receive(:delete)
        end

        subject.delete_files(files_to_delete: files_to_delete)
      end
    end

    describe '#download' do
      let(:file_names) do
        [
          'ABCDEFG/certs/development/ABCDEFG.cer',
          'ABCDEFG/certs/development/ABCDEFG.p12'
        ]
      end

      let(:secure_files) do
        file_names.map.with_index do |file_name, index|
          Match::Storage::GitLab::SecureFile.new(file: { id: index, name: file_name }, client: subject.gitlab_client)
        end
      end

      it 'downloads to correct working directory' do
        expect(subject.gitlab_client).to receive(:files).and_return(secure_files)

        secure_files.each_with_index do |secure_file, index|
          expect(secure_file.file.name).to eq(file_names[index])
          expect(secure_file).to receive(:download).with(working_directory)
        end

        subject.download
      end
    end

    describe '#human_readable_description' do
      it 'returns the correct human readable description for the configured storage mode' do
        expect(subject.human_readable_description).to eq('GitLab Secure Files Storage [fake-project]')
      end
    end

    describe '#generate_matchfile_content' do
      it 'returns the correct match file contents for the configured storage mode and project path' do
        expect(FastlaneCore::UI).to receive(:input).once.and_return("fake-project")
        expect(FastlaneCore::UI).to receive(:input).once.and_return(nil)

        expect(subject.generate_matchfile_content).to eq('gitlab_project("fake-project")')
      end

      it 'returns the correct match file contents for the configured storage mode and project path and gitlab host' do
        expect(FastlaneCore::UI).to receive(:input).once.and_return("fake-project")
        expect(FastlaneCore::UI).to receive(:input).once.and_return("https://gitlab.example.com")

        expect(subject.generate_matchfile_content).to eq("gitlab_project(\"fake-project\")\ngitlab_host(\"https://gitlab.example.com\")")
      end
    end
  end
end
