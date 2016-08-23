require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  describe Command::List do
    before do
      installer.stub(:exists).and_return(true)
      installer.stub(:installed_versions).and_return([])
    end

    def installer
      @installer ||= Installer.new
    end

    def fake_xcode(name)
      fixture = Pathname.new('spec/fixtures/xcode_63.json').read
      xcode = Xcode.new(JSON.parse(fixture))
      xcode.stub(:name).and_return(name)
      xcode
    end

    def fake_xcodes(*names)
      xcodes = names.map { |name| fake_xcode(name) }
      installer.stub(:xcodes).and_return(xcodes)
    end

    describe '#list' do
      it 'lists all versions' do
        fake_xcodes '1', '2.3', '3 some', '4 beta'
        expect(installer.list).to eq("1\n2.3\n3 some\n4 beta")
      end
    end

    describe '#list_current' do
      it 'shows versions from latest version only' do
        fake_xcodes '2', '3.0', '3.1', '1.1'
        expect(installer.list_current).to eq("3.0\n3.1")
      end

      it 'shows versions of new beta releases too' do
        fake_xcodes '5', '6.1', '6', '6.4 beta', '7 beta'
        expect(installer.list_current).to eq("6\n6.1\n6.4 beta\n7 beta")
      end
    end
  end
end
