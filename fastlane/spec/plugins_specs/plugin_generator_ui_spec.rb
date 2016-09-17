describe Fastlane::PluginGeneratorUI do
  let(:ui) { Fastlane::PluginGeneratorUI.new }

  describe '#message' do
    it 'calls puts' do
      expect(ui).to receive(:puts).with('hi')
      ui.message('hi')
    end
  end

  describe '#input' do
    it 'calls UI#input' do
      expect(UI).to receive(:input).with('hi')
      ui.input('hi')
    end
  end

  describe '#confirm' do
    it 'calls UI#confirm' do
      expect(UI).to receive(:confirm).with('hi')
      ui.confirm('hi')
    end
  end
end
