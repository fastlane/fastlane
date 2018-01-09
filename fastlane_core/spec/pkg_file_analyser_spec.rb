describe FastlaneCore do
  describe FastlaneCore::PkgFileAnalyser do
    let(:path) { File.expand_path("../fixtures/pkgs/#{pkg}.pkg", __FILE__) }

    context "with a normal path" do
      let(:pkg) { 'MacAppOnly' }

      describe '::fetch_app_identifier' do
        subject { described_class.fetch_app_identifier(path) }
        it { is_expected.to eq('com.example.Sample') }
      end
      describe '::fetch_app_version' do
        subject { described_class.fetch_app_version(path) }
        it { is_expected.to eq('1.0') }
      end
    end

    context "with a path containing spaces" do
      let(:pkg) { 'Spaces in Path' }

      describe '::fetch_app_identifier' do
        subject { described_class.fetch_app_identifier(path) }
        it { is_expected.to eq('com.example.Sample') }
      end
      describe '::fetch_app_version' do
        subject { described_class.fetch_app_version(path) }
        it { is_expected.to eq('1.0') }
      end
    end
  end
end
