require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  describe Command::InstallCLITools do
    it 'fails if tools are already installed' do
      Command::InstallCLITools.any_instance.should_receive(:installed?).and_return(true)
      expect { Command::InstallCLITools.run }.to raise_exception(SystemExit)
    end

    it 'runs if tools are not installed' do
      Command::InstallCLITools.any_instance.should_receive(:installed?).and_return(false)
      Command::InstallCLITools.any_instance.should_receive(:install)
      Command::InstallCLITools.run
    end
  end
end
