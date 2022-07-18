describe Match do
  describe Match::Storage::GitLab::Client do
    subject {
      described_class.new(
        api_v4_url: 'https://gitlab.example.com/api/v4',
        project_id: 'sample/project',
        private_token: 'abc123'
    )
    }

    describe '#base_url' do
      it 'returns the expected base_url for the given configuration' do
        expect(subject.base_url).to eq('https://gitlab.example.com/api/v4/projects/sample%2Fproject/secure_files')
      end
    end

    describe '#authentication_key' do
      it 'returns the job_token header key if job_token defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project',
          job_token: 'abc123'
        )
        expect(client.authentication_key).to eq('JOB-TOKEN')
      end

      it 'returns private_token header key if private_key defined and job_token is not defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project',
          private_token: 'xyz123'
        )
        expect(client.authentication_key).to eq('PRIVATE-TOKEN')
      end

      it 'returns the job_token header key if both job_token and private_token are defined, and prints a warning to the logs' do
        expect_any_instance_of(FastlaneCore::Shell).to receive(:important).with("JOB_TOKEN and PRIVATE_TOKEN both defined, using JOB_TOKEN to execute this job.")

        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project',
          job_token: 'abc123',
          private_token: 'xyz123'
        )
        expect(client.authentication_key).to eq('JOB-TOKEN')
      end

      it 'returns nil if job_token and private_token are both undefined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project'
        )
        expect(client.authentication_key).to be_nil
      end
    end

    describe '#authentication_value' do
      it 'returns the job_token value if job_token defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project',
          job_token: 'abc123'
        )
        expect(client.authentication_value).to eq('abc123')
      end

      it 'returns private_token value if private_key defined and job_token is not defined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project',
          private_token: 'xyz123'
        )
        expect(client.authentication_value).to eq('xyz123')
      end

      it 'returns the job_token value if both job_token and private_token are defined, and prints a warning to the logs' do
        expect_any_instance_of(FastlaneCore::Shell).to receive(:important).with("JOB_TOKEN and PRIVATE_TOKEN both defined, using JOB_TOKEN to execute this job.")

        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project',
          job_token: 'abc123',
          private_token: 'xyz123'
        )
        expect(client.authentication_value).to eq('abc123')
      end

      it 'returns nil if job_token and private_token are both undefined' do
        client = described_class.new(
          api_v4_url: 'https://gitlab.example.com/api/v4',
          project_id: 'sample/project'
        )
        expect(client.authentication_value).to be_nil
      end
    end

    describe '#files' do
      it 'returns an array of secure files for a project' do
        response = [
          { id: 1, name: 'file1' },
          { id: 2, name: 'file2' }
        ].to_json

        stub_request(:get, /gitlab.example.com/).
          with(headers: { 'PRIVATE-TOKEN' => 'abc123' }).
          to_return(status: 200, body: response)

        files = subject.files
        expect(files.count).to be(2)
        expect(files.first.file.name).to eq('file1')
      end

      it 'returns an empty array if there are results' do
        stub_request(:get, /gitlab.example.com/).
          with(headers: { 'PRIVATE-TOKEN' => 'abc123' }).
          to_return(status: 200, body: [].to_json)

        expect(subject.files.count).to be(0)
      end

      it 'raises an exception for a non-json response' do
        stub_request(:get, /gitlab.example.com/).
          with(headers: { 'PRIVATE-TOKEN' => 'abc123' }).
          to_return(status: 200, body: 'foo')

        expect { subject.files }.to raise_error(JSON::ParserError)
      end
    end

    describe '#log_upload_error' do
      it 'logs a custom error message when the file name has already been taken' do
        expect_any_instance_of(FastlaneCore::Shell).to receive(:error).with("foo already exists in GitLab project sample/project, file not uploaded")

        response_body = { message: { name: ["has already been taken" ] } }.to_json
        response = OpenStruct.new(code: "400", body: response_body)
        target_file = 'foo'
        subject.log_upload_error(response, target_file)
      end

      it 'logs the returned error message when an unexpected JSON response is returned' do
        expect_any_instance_of(FastlaneCore::Shell).to receive(:error).with("Upload error for foo: {\"message\"=>{\"bar\"=>\"baz\"}}")

        response_body = { message: { bar: "baz" } }.to_json
        response = OpenStruct.new(code: "500", body: response_body)
        target_file = 'foo'
        subject.log_upload_error(response, target_file)
      end

      it 'logs the returned error message when an unexpected JSON response is returned' do
        expect_any_instance_of(FastlaneCore::Shell).to receive(:error).with("Upload error for foo: {\"foo\"=>{\"bar\"=>\"baz\"}}")

        response_body = { foo: { bar: "baz" } }.to_json
        response = OpenStruct.new(code: "500", body: response_body)
        target_file = 'foo'
        subject.log_upload_error(response, target_file)
      end

      it 'logs the returned error message when a non-JSON response is returned' do
        expect_any_instance_of(FastlaneCore::Shell).to receive(:error).with("Upload error for foo: a generic error message")

        response = OpenStruct.new(code: "500", body: "a generic error message")
        target_file = 'foo'
        subject.log_upload_error(response, target_file)
      end
    end
  end
end
