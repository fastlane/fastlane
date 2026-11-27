describe Fastlane do
  describe Fastlane::FastFile do
    describe "download_universal_apk_from_google_play" do
      let(:client_stub) { instance_double(Supply::Client) }
      let(:package_name) { 'com.fastlane.myapp' }
      let(:version_code) { 1337 }
      let(:json_key_path) { File.expand_path("./fastlane/spec/fixtures/google_play/google_play.json") }
      let(:destination) { '/tmp/universal-apk/fastlane-generated-apk-spec.apk' }

      let(:cert_sha_1) { '01:02:03:04:05:06:07:08:09:0a:0b:0c:0d:0e:0f:10:11:12:13:14:15:16:17:18:19:1a:1b:1c:1d:1e:1f:20' }
      let(:download_id_1) { 'Stub_Id_For_Cert_1' }
      let(:cert_sha_2) { 'a1:a2:a3:a4:a5:a6:a7:a8:a9:aa:ab:ac:ad:ae:af:b0:b1:b2:b3:b4:b5:b6:b7:b8:b9:ba:bb:bc:bd:be:bf:c0' }
      let(:download_id_2) { 'Stub_Id_For_Cert_2' }
      let(:cert_sha_not_found) { '00:de:ad:00:be:ef:00:00:ba:ad:00:ca:fe:00:00:fe:ed:00:c0:ff:ee:00:b4:00:f0:0d:00:00:12:34:56:78' }
      let(:cert_sha_invalid_format) { cert_sha_1.gsub(':', '') }
      let(:cert_sha_too_short) { '13:37:00:42' }

      before :each do
        allow(Supply::Client).to receive_message_chain(:make_from_config).and_return(client_stub)
      end

      def stub_client_list(download_id_per_cert)
        response = download_id_per_cert.map do |cert_hash, download_id|
          Supply::GeneratedUniversalApk.new(package_name, version_code, cert_hash, download_id)
        end
        allow(client_stub).to receive(:list_generated_universal_apks)
          .with(package_name: package_name, version_code: version_code)
          .and_return(response)
      end

      context 'when no `certificate_sha256_hash` is provided' do
        it 'finds and download the only generated APK' do
          stub_client_list({ cert_sha_1 => download_id_1 })
          expected_ref = Supply::GeneratedUniversalApk.new(package_name, version_code, cert_sha_1, download_id_1)
          expect(FileUtils).to receive(:mkdir_p).with('/tmp/universal-apk')
          expect(client_stub).to receive(:download_generated_universal_apk)
            .with(generated_universal_apk: expected_ref, destination: destination)

          result = Fastlane::FastFile.new.parse("lane :test do
            download_universal_apk_from_google_play(
              package_name: '#{package_name}',
              version_code: '#{version_code}',
              json_key: '#{json_key_path}',
              destination: '#{destination}'
            )
          end").runner.execute(:test)

          expect(result).to eq(destination)
        end

        it 'raises if it finds more than one APK' do
          stub_client_list({ cert_sha_1 => download_id_1, cert_sha_2 => download_id_2 })
          expect(client_stub).not_to receive(:download_generated_universal_apk)
          expected_error = <<~ERROR
            We found multiple Generated Universal APK, with the following `certificate_sha256_hash`:
             - #{cert_sha_1}
             - #{cert_sha_2}

            Use the `certificate_sha256_hash` parameter to specify which one to download.
          ERROR

          expect {
            Fastlane::FastFile.new.parse("lane :test do
              download_universal_apk_from_google_play(
                package_name: '#{package_name}',
                version_code: '#{version_code}',
                json_key: '#{json_key_path}',
                destination: '#{destination}'
              )
            end").runner.execute(:test)
          }.to raise_error(FastlaneCore::Interface::FastlaneError, expected_error)
        end
      end

      context 'when a `certificate_sha256_hash` is provided' do
        it 'finds a matching APK and downloads it' do
          stub_client_list({ cert_sha_1 => download_id_1, cert_sha_2 => download_id_2 })
          expected_ref = Supply::GeneratedUniversalApk.new(package_name, version_code, cert_sha_2, download_id_2)
          expect(FileUtils).to receive(:mkdir_p).with('/tmp/universal-apk')
          expect(client_stub).to receive(:download_generated_universal_apk)
            .with(generated_universal_apk: expected_ref, destination: destination)

          result = Fastlane::FastFile.new.parse("lane :test do
            download_universal_apk_from_google_play(
              package_name: '#{package_name}',
              version_code: '#{version_code}',
              json_key: '#{json_key_path}',
              destination: '#{destination}',
              certificate_sha256_hash: '#{cert_sha_2}'
            )
          end").runner.execute(:test)

          expect(result).to eq(destination)
        end

        it 'errors if it does not find any matching APK' do
          stub_client_list({ cert_sha_1 => download_id_1, cert_sha_2 => download_id_2 })
          expected_error = <<~ERROR
            None of the Universal APK(s) found for this version code matched the `certificate_sha256_hash` of `#{cert_sha_not_found}`.

            We found 2 Generated Universal APK(s), but with a different `certificate_sha256_hash`:
             - #{cert_sha_1}
             - #{cert_sha_2}
          ERROR

          expect {
            Fastlane::FastFile.new.parse("lane :test do
              download_universal_apk_from_google_play(
                package_name: '#{package_name}',
                version_code: '#{version_code}',
                json_key: '#{json_key_path}',
                destination: '#{destination}',
                certificate_sha256_hash: '#{cert_sha_not_found}'
              )
            end").runner.execute(:test)
          }.to raise_error(FastlaneCore::Interface::FastlaneError, expected_error)
        end
      end

      context 'when invalid input parameters are provided' do
        it 'reports an error if the destination is not a path to an apk file' do
          expected_error = "The 'destination' must be a file path with the `.apk` file extension"
          expect {
            Fastlane::FastFile.new.parse("lane :test do
              download_universal_apk_from_google_play(
                package_name: '#{package_name}',
                version_code: '#{version_code}',
                json_key: '#{json_key_path}',
                destination: '/tmp/somedir/'
              )
            end").runner.execute(:test)
          }.to raise_error(FastlaneCore::Interface::FastlaneError, expected_error)
        end

        it 'reports an error if the cert sha is not in the right format' do
          expected_error = "When provided, the certificate sha256 must be in the 'xx:xx:xx:…:xx' (32 hex bytes separated by colons) format"
          expect {
            Fastlane::FastFile.new.parse("lane :test do
              download_universal_apk_from_google_play(
                package_name: '#{package_name}',
                version_code: '#{version_code}',
                json_key: '#{json_key_path}',
                destination: '#{destination}',
                certificate_sha256_hash: '#{cert_sha_invalid_format}'
              )
            end").runner.execute(:test)
          }.to raise_error(FastlaneCore::Interface::FastlaneError, expected_error)
        end

        it 'reports an error if the cert sha is not of the right length' do
          expected_error = "When provided, the certificate sha256 must be in the 'xx:xx:xx:…:xx' (32 hex bytes separated by colons) format"
          expect {
            Fastlane::FastFile.new.parse("lane :test do
              download_universal_apk_from_google_play(
                package_name: '#{package_name}',
                version_code: '#{version_code}',
                json_key: '#{json_key_path}',
                destination: '#{destination}',
                certificate_sha256_hash: '#{cert_sha_too_short}'
              )
            end").runner.execute(:test)
          }.to raise_error(FastlaneCore::Interface::FastlaneError, expected_error)
        end
      end
    end
  end
end
