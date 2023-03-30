describe Match do
  describe Match::Storage::AWSSecretsManagerStorage do
    stub_request(:put, "http://169.254.169.254/latest/api/token").
      with(
        headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'aws-sdk-ruby3/3.167.0',
        'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
        }
    ).
      to_return(status: 200, body: "", headers: {})
    subject { described_class.new(aws_secrets_manager_region: nil, aws_secrets_manager_access_key: nil, aws_secrets_manager_secret_access_key: nil, team_id: 'test_team_id') }
    let(:working_directory) { '/var/folders/px/abcdefghijklmnop/T/d20181026-96528-1av4gge' }

    before do
      allow(subject).to receive(:working_directory).and_return(working_directory)
      allow(subject).to receive(:aws_sm_client).and_return(aws_sm_client)
    end

    describe '#upload_files' do
      let(:files_to_upload) do
        [
          "#{working_directory}/ABCDEFG/certs/development/ABCDEFG.cer",
          "#{working_directory}/ABCDEFG/certs/development/ABCDEFG.p12"
        ]
      end
      let(:aws_sm_client) { double(describe_secret: { arn: 'arn:secretsmanager:test' }, update_secret: { arn: 'arn:secretsmanager:test' }) }
      let!(:file) { class_double('File', read: 'body').as_stubbed_const }

      it 'reads the correct files from local storage' do
        files_to_upload.each do |file_name|
          expect(file).to receive(:read).with(file_name)
        end

        subject.upload_files(files_to_upload: files_to_upload)
      end

      it 'updates secrets with the correct keys in AWS SM' do
        stub_request(:put, "http://169.254.169.254/latest/api/token").
          with(
            headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'User-Agent' => 'aws-sdk-ruby3/3.167.0',
            'X-Aws-Ec2-Metadata-Token-Ttl-Seconds' => '21600'
            }
        ).
          to_return(status: 200, body: "", headers: {})
        expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer' })
        expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12' })

        expect(aws_sm_client).to receive(:update_secret).with({
          secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer',
          secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
        })
        expect(aws_sm_client).to receive(:update_secret).with({
          secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12',
          secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
        })

        subject.upload_files(files_to_upload: files_to_upload)
      end

      describe "#update_files" do
        let(:aws_sm_client) { double(describe_secret: { deleted_date: "deleted date here" }, update_secret: { arn: 'arn:secretsmanager:test' }, restore_secret: {}) }
        it 'restores and updates secrets with the correct keys in AWS SM' do
          expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer' })
          expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12' })

          expect(aws_sm_client).to receive(:restore_secret).with({
              secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer'
          })
          expect(aws_sm_client).to receive(:restore_secret).with({
              secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12'
          })

          expect(aws_sm_client).to receive(:update_secret).with({
              secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer',
              secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
          })
          expect(aws_sm_client).to receive(:update_secret).with({
              secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12',
              secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
          })

          subject.upload_files(files_to_upload: files_to_upload)
        end
      end

      it 'creates secrets if they do not exist' do
        expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer' }).and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new(nil, nil))
        expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12' }).and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new(nil, nil))

        expect(aws_sm_client).to receive(:create_secret).with({
            name: 'ABCDEFG/certs/development/ABCDEFG.cer',
            secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
          })
        expect(aws_sm_client).to receive(:create_secret).with({
              name: 'ABCDEFG/certs/development/ABCDEFG.p12',
              secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
          })

        subject.upload_files(files_to_upload: files_to_upload)
      end

      it 'uploads files with aws_secrets_manager_prefix if set' do
        allow(subject).to receive(:prefix).and_return('123456/')

        expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: '123456/ABCDEFG/certs/development/ABCDEFG.cer' }).and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new(nil, nil))
        expect(aws_sm_client).to receive(:describe_secret).with({ secret_id: '123456/ABCDEFG/certs/development/ABCDEFG.p12' }).and_raise(Aws::SecretsManager::Errors::ResourceNotFoundException.new(nil, nil))

        expect(aws_sm_client).to receive(:create_secret).with({
          name: '123456/ABCDEFG/certs/development/ABCDEFG.cer',
          secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
        })
        expect(aws_sm_client).to receive(:create_secret).with({
          name: '123456/ABCDEFG/certs/development/ABCDEFG.p12',
          secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
        })

        subject.upload_files(files_to_upload: files_to_upload)
      end
    end

    describe '#delete_files' do
      let(:files_to_delete) do
        [
          "#{working_directory}/ABCDEFG/certs/development/ABCDEFG.cer",
          "#{working_directory}/ABCDEFG/certs/development/ABCDEFG.p12"
        ]
      end
      let(:aws_sm_client) { double(delete_secret: {}) }

      it 'deletes files with correct paths and correct skip recovery setting' do
        allow(subject).to receive(:delete_without_recovery).and_return(true)

        expect(aws_sm_client).to receive(:delete_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer', force_delete_without_recovery: true })
        expect(aws_sm_client).to receive(:delete_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12', force_delete_without_recovery: true })

        subject.delete_files(files_to_delete: files_to_delete)
      end

      it 'deletes files with correct paths and correct recovery_window_in_days setting' do
        allow(subject).to receive(:recovery_window_days).and_return(10)

        expect(aws_sm_client).to receive(:delete_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.cer', recovery_window_in_days: 10 })
        expect(aws_sm_client).to receive(:delete_secret).with({ secret_id: 'ABCDEFG/certs/development/ABCDEFG.p12', recovery_window_in_days: 10 })

        subject.delete_files(files_to_delete: files_to_delete)
      end

      it 'deletes files with aws_secrets_manager_prefix if set' do
        allow(subject).to receive(:prefix).and_return('123456/')

        expect(aws_sm_client).to receive(:delete_secret).with({ secret_id: '123456/ABCDEFG/certs/development/ABCDEFG.cer' })
        expect(aws_sm_client).to receive(:delete_secret).with({ secret_id: '123456/ABCDEFG/certs/development/ABCDEFG.p12' })

        subject.delete_files(files_to_delete: files_to_delete)
      end
    end

    describe '#download' do
      let(:secrets_to_download) {
        [
          instance_double('Aws::SecretsManager::Types::SecretListEntry', name: 'ABCDEFG/certs/development/ABCDEFG.cer', arn: 'arn:secretsmanager:123456/ABCDEFG/certs/development/ABCDEFG.cer'),
          instance_double('Aws::SecretsManager::Types::SecretListEntry', name: 'ABCDEFG/certs/development/ABCDEFG.p12', arn: 'arn:secretsmanager:123456/ABCDEFG/certs/development/ABCDEFG.p12')
        ]
      }
      let(:secrets_list_to_download) { instance_double('Types::ListSecretsResponse', secret_list: secrets_to_download, next_token: nil) }

      let(:aws_sm_client) {
        instance_double('Aws::SecretsManager::Client',
                        get_secret_value: double({
                              secret_binary: Base64.encode64(Zlib::Deflate.deflate('body'))
                          }),
                          list_secrets: secrets_list_to_download)
      }

      before {
        class_double('FileUtils', mkdir_p: true).as_stubbed_const
        allow(subject).to receive(:currently_used_team_id).and_return("test_team_id")
      }

      it 'downloads to correct working directory' do
        expect(aws_sm_client).to receive(:list_secrets).with({ filters: [{ key: "name", values: ["test_team_id"] }], max_results: 100 })

        secrets_to_download.each do |secret|
          expect(aws_sm_client).to receive(:get_secret_value).with({ secret_id: secret.arn })
        end

        expect(File).to receive(:write).with("#{working_directory}/ABCDEFG/certs/development/ABCDEFG.cer", 'body')
        expect(File).to receive(:write).with("#{working_directory}/ABCDEFG/certs/development/ABCDEFG.p12", 'body')

        subject.download
      end

      it 'downloads secrets and strips the aws_secrets_manager_prefix for working_directory path' do
        allow(subject).to receive(:prefix).and_return('123456/')

        expect(aws_sm_client).to receive(:list_secrets).with({ filters: [{ key: "name", values: ["123456/test_team_id"] }], max_results: 100 })

        secrets_to_download.each do |secret|
          expect(aws_sm_client).to receive(:get_secret_value).with({ secret_id: secret.arn })
        end

        expect(File).to receive(:write).with("#{working_directory}/ABCDEFG/certs/development/ABCDEFG.cer", 'body')
        expect(File).to receive(:write).with("#{working_directory}/ABCDEFG/certs/development/ABCDEFG.p12", 'body')

        subject.download
      end
    end
  end
end
