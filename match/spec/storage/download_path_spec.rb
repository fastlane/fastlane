describe Match::Storage do
  describe '.download_path' do
    let(:working_directory) { File.expand_path('/tmp/match-wd') }

    it 'places a nested name inside the working directory' do
      expect(described_class.download_path(working_directory, 'TEAMID/certs/distribution/CERTID.p12')).to eq(File.join(working_directory, 'TEAMID/certs/distribution/CERTID.p12'))
    end

    it 'accepts .. segments that stay inside' do
      expect(described_class.download_path(working_directory, 'TEAMID/certs/../profiles/a.mobileprovision')).to eq(File.join(working_directory, 'TEAMID/profiles/a.mobileprovision'))
    end

    it 'keeps a name starting with / inside' do
      expect(described_class.download_path(working_directory, '/certs/a.cer')).to eq(File.join(working_directory, 'certs/a.cer'))
    end

    ['../a.cer', 'TEAMID/../../a.cer', 'TEAMID/certs/../../../a.cer', '..'].each do |name|
      it "refuses #{name.inspect}, which is outside" do
        expect { described_class.download_path(working_directory, name) }.to raise_error(FastlaneCore::Interface::FastlaneError, /Refusing to download #{Regexp.escape(name.inspect)}/)
      end
    end

    it 'refuses a sibling directory sharing the working directory name as a prefix' do
      expect { described_class.download_path(working_directory, '../match-wd-other/a.cer') }.to raise_error(FastlaneCore::Interface::FastlaneError)
    end
  end
end
