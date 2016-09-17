describe Screengrab::Runner do
  let(:config) { {} }
  let(:ui) { Screengrab::UI }
  let(:mock_android_environment) { double(Screengrab.android_environment) }
  let(:mock_executor) { class_double('FastlaneCore::CommandExecutor') }

  before do
    @runner = Screengrab::Runner.new(mock_executor, config, mock_android_environment)
  end

  def set_mock_adb_response(command, mock_response)
    expect(mock_executor).to receive(:execute)
      .with(hash_including(command: command))
      .and_return(mock_response)
  end

  describe :validate_apk do
    context 'no aapt' do
      it 'prints an error unless aapt can be found' do
        expect(mock_android_environment).to receive(:aapt_path).and_return nil
        expect(mock_executor).not_to receive(:execute)
        expect(ui).to receive(:important).with(/.*aapt.*could not be found/)

        @runner.validate_apk('fake_apk_path')
      end
    end

    context 'no permissions' do
      it 'prints if permissions are missing' do
        allow(mock_android_environment).to receive(:aapt_path).and_return 'fake_aapt_path'
        set_mock_adb_response('fake_aapt_path dump permissions fake_apk_path', '')

        expect(ui).to receive(:user_error!).with(/permission.* could not be found/).and_call_original

        expect { @runner.validate_apk('fake_apk_path') }.to raise_fastlane_error
      end
    end
  end

  describe :select_device do
    let (:adb_list_devices_command) { 'adb devices -l' }

    context 'no devices' do
      it 'does not find any active devices' do
        adb_response = <<-ADB_OUTPUT.strip_heredoc
        List of devices attached

        ADB_OUTPUT
        set_mock_adb_response(adb_list_devices_command, adb_response)

        expect(ui).to receive(:user_error!).with(/no connected.* devices/).and_call_original

        expect { @runner.select_device }.to raise_fastlane_error
      end
    end

    context 'one device' do
      it 'finds an active device' do
        adb_response = <<-ADB_OUTPUT.strip_heredoc
          List of devices attached
          T065002LTT             device usb:437387264X product:ghost_retail model:XT1053 device:ghost


        ADB_OUTPUT
        set_mock_adb_response(adb_list_devices_command, adb_response)

        expect(@runner.select_device).to eq('T065002LTT')
      end
    end

    context 'multiple devices' do
      it 'finds an active device' do
        adb_response = <<-ADB_OUTPUT.strip_heredoc
          List of devices attached
          emulator-5554          device product:sdk_phone_x86_64 model:Android_SDK_built_for_x86_64 device:generic_x86_64
          T065002LTT             device usb:437387264X product:ghost_retail model:XT1053 device:ghost

        ADB_OUTPUT

        set_mock_adb_response(adb_list_devices_command, adb_response)
        expect(@runner.select_device).to eq('emulator-5554')
      end
    end

    context 'one device booting' do
      it 'finds an active device' do
        adb_response = <<-ADB_OUTPUT.strip_heredoc
          List of devices attached
          emulator-5554 offline
          T065002LTT  device

        ADB_OUTPUT

        set_mock_adb_response(adb_list_devices_command, adb_response)

        expect(@runner.select_device).to eq('T065002LTT')
      end
    end
  end

  describe :run_adb_command do
    it 'filters out lines which are ADB warnings' do
      adb_response = <<-ADB_OUTPUT.strip_heredoc
            adb: /home/me/rubystack-2.3.1-4/common/lib/libcrypto.so.1.0.0: no version information available (required by adb)
            List of devices attached
            e1dbf228               device usb:1-1.2 product:a33gdd model:SM_A300H device:a33g

          ADB_OUTPUT

      set_mock_adb_response("test", adb_response)

      expect(@runner.run_adb_command("test").lines.any? { |line| line.start_with?('adb: ') }).to eq(false)
    end
  end
end
