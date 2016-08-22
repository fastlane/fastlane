require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  describe Command::InstallCLITools do
    it 'fails if tools are already installed' do
      Command::InstallCLITools.any_instance.expects(:installed?).returns(true)
      -> { Command::InstallCLITools.run }.should.raise(SystemExit)
    end

    it 'runs if tools are not installed' do
      Command::InstallCLITools.any_instance.expects(:installed?).returns(false)
      Command::InstallCLITools.any_instance.expects(:install)
      Command::InstallCLITools.run
    end
  end
end
