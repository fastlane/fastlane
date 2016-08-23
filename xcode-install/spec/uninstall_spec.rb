require File.expand_path('../spec_helper', __FILE__)

module XcodeInstall
  describe Command::Uninstall do
    describe 'when invoked' do
      it 'raise error when the version is not specified' do
        Command::Uninstall.any_instance.should_receive(:help!)
        expect { Command::Uninstall.run([]) }.to raise_exception(Exception)
      end
    end
  end
end
