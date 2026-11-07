describe FastlaneCore do
  describe FastlaneCore::PkgFileAnalyser do
    let(:path) { File.expand_path("../fixtures/pkgs/#{pkg}.pkg", __FILE__) }

    context "with a normal path" do
      let(:pkg) { 'MacAppOnly' }

      describe '::fetch_app_identifier', requires_xar: true do
        subject { described_class.fetch_app_identifier(path) }
        it { is_expected.to eq('com.example.Sample') }
      end
      describe '::fetch_app_version', requires_xar: true do
        subject { described_class.fetch_app_version(path) }
        it { is_expected.to eq('1.0') }
      end
    end

    context "with a file xar cannot read", requires_xar: true do
      it "fails with xar's message" do
        Tempfile.create(["not_a_pkg", ".pkg"]) do |file|
          file.write("not a xar archive")
          file.close

          expect do
            described_class.fetch_app_identifier(file.path)
          end.to raise_error(FastlaneCore::Interface::FastlaneError, /Could not extract '#{Regexp.escape(file.path)}'.*Error opening xar archive/m)
        end
      end
    end

    context "with a path containing spaces" do
      let(:pkg) { 'Spaces in Path' }

      describe '::fetch_app_identifier', requires_xar: true do
        subject { described_class.fetch_app_identifier(path) }
        it { is_expected.to eq('com.example.Sample') }
      end
      describe '::fetch_app_version', requires_xar: true do
        subject { described_class.fetch_app_version(path) }
        it { is_expected.to eq('1.0') }
      end
    end
  end
end
