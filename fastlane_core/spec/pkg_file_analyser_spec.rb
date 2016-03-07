describe FastlaneCore do
  describe FastlaneCore::PkgFileAnalyser do
    let(:pkg) { 'MacAppOnly' }
    let(:path) { File.expand_path("../fixtures/pkgs/#{pkg}.pkg", __FILE__) }
    describe '::fetch_app_identifier' do
      subject { described_class.fetch_app_identifier(path) }
      it { is_expected.to eq 'com.example.Sample' }
    end
    describe '::fetch_app_version' do
      subject { described_class.fetch_app_version(path) }
      it { is_expected.to eq '1.0' }
    end
  end
end
