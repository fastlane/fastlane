describe Screengrab::Runner do
  let(:config) { {} }
  let(:ui) { Screengrab::UI }
  let(:mock_android_environment) { double(Screengrab.android_environment) }
  let(:mock_executor) { class_double('FastlaneCore::CommandExecutor') }

  before do
    @runner = Screengrab::Runner.new(mock_executor, config, mock_android_environment)
  end

  def mock_adb_response_for_command(command, mock_response)
    expect(mock_executor).to receive(:execute)
      .with(hash_including(command: command))
      .and_return(mock_response)
  end

  def mock_adb_response(mock_response)
    expect(mock_executor).to receive(:execute)
      .and_return(mock_response)
  end

  describe :run_tests_for_locale do
    let(:device_serial) { 'device_serial' }
    let(:test_classes_to_use) { nil }
    let(:test_packages_to_use) { nil }

    context "when launch arguments are specified" do
      before do
        config[:launch_arguments] = ["username hjanuschka", "build_type x500"]
        config[:locales] = %w(en-US)
        config[:ending_locale] = 'en-US'
      end
      it 'sets custom launch_arguments' do
        expect(mock_executor).to receive(:execute)
          .with(hash_including(command: "adb -s device_serial shell am instrument --no-window-animation -w \\\n-e testLocale en_US \\\n-e endingLocale en_US \\\n-e username hjanuschka -e build_type x500 \\\n/"))
        @runner.run_tests_for_locale('en-US', device_serial, test_classes_to_use, test_packages_to_use, config[:launch_arguments])
      end
    end

    context 'when a locale is specified' do
      before do
        config[:locales] = %w(en-US)
        config[:ending_locale] = 'en-US'
      end

      context 'when tests produce a failure' do
        before do
          mock_adb_response('FAILURES!!!')
        end

        context 'when exit_on_test_failure is true' do
          before do
            config[:exit_on_test_failure] = true
          end

          it 'prints an error and exits the program' do
            expect(ui).to receive(:test_failure!).with("Tests failed for locale en-US on device #{device_serial}").and_call_original

            expect { @runner.run_tests_for_locale('en-US', device_serial, test_classes_to_use, test_packages_to_use, nil) }.to raise_fastlane_test_failure
          end
        end

        context 'when exit_on_test_failure is false' do
          before do
            config[:exit_on_test_failure] = false
          end

          it 'prints an error and does not exit the program' do
            expect(ui).to receive(:error).with("Tests failed").and_call_original

            @runner.run_tests_for_locale('en-US', device_serial, test_classes_to_use, test_packages_to_use, nil)
          end
        end
      end
    end
  end

  describe :validate_apk do
    context 'no aapt' do
      it 'prints an error unless aapt can be found' do
        expect(mock_android_environment).to receive(:aapt_path).and_return(nil)
        expect(mock_executor).not_to(receive(:execute))
        expect(ui).to receive(:important).with(/.*aapt.*could not be found/)

        @runner.validate_apk('fake_apk_path')
      end
    end

    context 'no permissions' do
      it 'prints if permissions are missing' do
        allow(mock_android_environment).to receive(:aapt_path).and_return('fake_aapt_path')
        mock_adb_response_for_command('fake_aapt_path dump permissions fake_apk_path', '')

        expect(ui).to receive(:user_error!).with(/permission.* could not be found/).and_call_original

        expect { @runner.validate_apk('fake_apk_path') }.to raise_fastlane_error
      end
    end
  end

  describe :select_device do
    let(:adb_list_devices_command) { 'adb devices -l' }

    context 'no devices' do
      it 'does not find any active devices' do
        adb_response = strip_heredoc(<<-ADB_OUTPUT)
        List of devices attached

        ADB_OUTPUT
        mock_adb_response_for_command(adb_list_devices_command, adb_response)

        expect(ui).to receive(:user_error!).with(/no connected.* devices/).and_call_original

        expect { @runner.select_device }.to raise_fastlane_error
      end
    end

    context 'one device with spurious ADB output mixed in' do
      it 'finds an active device' do
        adb_response = strip_heredoc(<<-ADB_OUTPUT)
          List of devices attached
          adb server version (39) doesn't match this client (36); killing...
          * daemon started successfully
          T065002LTT             device usb:437387264X product:ghost_retail model:XT1053 device:ghost


        ADB_OUTPUT
        mock_adb_response_for_command(adb_list_devices_command, adb_response)

        expect(@runner.select_device).to eq('T065002LTT')
      end
    end

    context 'one device' do
      it 'finds an active device' do
        adb_response = strip_heredoc(<<-ADB_OUTPUT)
          List of devices attached
          T065002LTT             device usb:437387264X product:ghost_retail model:XT1053 device:ghost


        ADB_OUTPUT
        mock_adb_response_for_command(adb_list_devices_command, adb_response)

        expect(@runner.select_device).to eq('T065002LTT')
      end
    end

    context 'multiple devices' do
      it 'finds an active device' do
        adb_response = strip_heredoc(<<-ADB_OUTPUT)
          List of devices attached
          emulator-5554          device product:sdk_phone_x86_64 model:Android_SDK_built_for_x86_64 device:generic_x86_64
          T065002LTT             device usb:437387264X product:ghost_retail model:XT1053 device:ghost

        ADB_OUTPUT

        mock_adb_response_for_command(adb_list_devices_command, adb_response)
        expect(@runner.select_device).to eq('emulator-5554')
      end
    end

    context 'one device booting' do
      it 'finds an active device' do
        adb_response = strip_heredoc(<<-ADB_OUTPUT)
          List of devices attached
          emulator-5554 offline
          T065002LTT  device

        ADB_OUTPUT

        mock_adb_response_for_command(adb_list_devices_command, adb_response)

        expect(@runner.select_device).to eq('T065002LTT')
      end
    end
  end

  describe :run_adb_command do
    it 'filters out lines which are ADB warnings' do
      adb_response = strip_heredoc(<<-ADB_OUTPUT)
            adb: /home/me/rubystack-2.3.1-4/common/lib/libcrypto.so.1.0.0: no version information available (required by adb)
            List of devices attached
            e1dbf228               device usb:1-1.2 product:a33gdd model:SM_A300H device:a33g

          ADB_OUTPUT

      mock_adb_response_for_command("test", adb_response)

      expect(@runner.run_adb_command("test").lines.any? { |line| line.start_with?('adb: ') }).to eq(false)
    end
  end
end
