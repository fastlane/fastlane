require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  describe Command::Install do
    describe 'when invoked' do
      before do
        Installer.any_instance.stub(:exists).and_return(true)
        Installer.any_instance.stub(:installed).and_return([])
        fixture = Pathname.new('spec/fixtures/xcode_63.json').read
        xcode = Xcode.new(JSON.parse(fixture))
        Installer.any_instance.stub(:seedlist).and_return([xcode])
      end

      it 'downloads and installs' do
        Installer.any_instance.should_receive(:download).with('6.3', true, nil).and_return('/some/path')
        Installer.any_instance.should_receive(:install_dmg).with('/some/path', '-6.3', true, true)
        Command::Install.run(['6.3'])
      end

      it 'downloads and installs with custom HTTP URL' do
        url = 'http://yolo.com/xcode.dmg'
        Installer.any_instance.should_receive(:download).with('6.3', true, url).and_return('/some/path')
        Installer.any_instance.should_receive(:install_dmg).with('/some/path', '-6.3', true, true)
        Command::Install.run(['6.3', "--url=#{url}"])
      end

      it 'downloads and installs and does not switch if --no-switch given' do
        Installer.any_instance.should_receive(:download).with('6.3', true, nil).and_return('/some/path')
        Installer.any_instance.should_receive(:install_dmg).with('/some/path', '-6.3', false, true)
        Command::Install.run(['6.3', '--no-switch'])
      end

      it 'downloads without progress if switch --no-progress is given' do
        Installer.any_instance.should_receive(:download).with('6.3', false, nil).and_return('/some/path')
        Installer.any_instance.should_receive(:install_dmg).with('/some/path', '-6.3', true, true)
        Command::Install.run(['6.3', '--no-progress'])
      end
    end

    it 'parses hdiutil output' do
      installer = Installer.new
      fixture = Pathname.new('spec/fixtures/hdiutil.plist').read
      installer.should_receive(:hdiutil).with('mount', '-plist', '-nobrowse', '-noverify', '/some/path').and_return(fixture)
      location = installer.send(:mount, Pathname.new('/some/path'))
      expect(location).to eq('/Volumes/XcodeME')
    end

    it 'gives more helpful error when downloaded DMG turns out to be HTML' do
      installer = Installer.new
      expect { installer.mount('spec/fixtures/mail-verify.html') }.to raise_error(Informative, /logging into your account from a browser/)
    end
  end
end
