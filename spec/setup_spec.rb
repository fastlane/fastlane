describe Fastlane do
  describe Fastlane::Setup do
    it "files_to_copy" do
      expect(Fastlane::Setup.new.files_to_copy).to eq(['Deliverfile', 'Snapfile', 'deliver', 'snapshot.js', 'SnapshotHelper.js', 'screenshots'])
    end
  end
end
