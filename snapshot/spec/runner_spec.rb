describe Snapshot do
  describe Snapshot::Runner do
    let(:runner) { Snapshot::Runner.new }
    describe 'Parses embedded SnapshotHelper.swift' do
      it 'finds the current embedded version' do
        helper_version = runner.version_of_bundled_helper
        expect(helper_version).to match(/^SnapshotHelperVersion \[\d.\d\]$/)
      end
    end
  end
end
