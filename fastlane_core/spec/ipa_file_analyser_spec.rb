describe FastlaneCore do
  describe FastlaneCore::IpaFileAnalyser do
    let(:ipa) { 'iOSAppOnly' }
    let(:path) { File.expand_path("../fixtures/ipas/#{ipa}.ipa", __FILE__) }
    describe '::fetch_app_identifier' do
      subject { described_class.fetch_app_identifier(path) }
      it { is_expected.to eq 'com.example.Sample' }
      context 'when contains embedded app bundle' do
        let('ipa') { 'ContainsWatchApp' }
        it { is_expected.to eq 'com.example.Sample' }
      end
    end
  end
end
