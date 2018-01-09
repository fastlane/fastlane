describe Fastlane::CrashlyticsBetaUi do
  describe 'present UI to the user in the terminal' do
    let(:ui) { Fastlane::CrashlyticsBetaUi.new }
    let(:current_schemes) { ['SchemeName', 'SchemeName2'] }

    it 'does not prompt the user to choose when not in interactive mode' do
      ENV["CI"] = "1"
      expect(Kernel).not_to(receive(:choose))
      ui.choose("\nWhich scheme would you like to use?", current_schemes)
    end

    it 'crashes when asking for input from the user not in interactive mode' do
      ENV["CI"] = "1"
      expect { ui.input("Input stuff") }.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end

    it 'crashes when asking for confirmation from the user not in interactive mode' do
      ENV["CI"] = "1"
      expect { ui.confirm("confirm stuff") }.to raise_error(FastlaneCore::Interface::FastlaneCrash)
    end
  end
end
