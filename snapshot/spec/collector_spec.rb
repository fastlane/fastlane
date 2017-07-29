describe Snapshot do
  describe Snapshot::Collector do
    describe '#attachments_in_file for Xcode 7.2.1 plist output' do
      it 'finds attachments and returns filenames' do
        expected_files = [
          "Screenshot_658CD3E2-96C5-4598-86EF-18164AEDE71D.png",
          "Screenshot_31FC792E-A9E9-4C04-A31D-9901EC425CD9.png",
          "Screenshot_AE21B4B1-6C45-44A2-BDF6-A30A33735688.png",
          "Screenshot_0B17C04E-5ED1-4667-AF31-EFDDCAC71EDB.png"
        ]
        expect(Snapshot::Collector.attachments_in_file('snapshot/spec/fixtures/Xcode-7_2_1-TestSummaries.plist')).to contain_exactly(*expected_files)
      end
    end

    describe '#attachments_in_file for Xcode 7.3 plist output' do
      it 'finds attachments and returns filenames' do
        expected_files = [
          "Screenshot_75B3F0C3-BF0E-44D5-B26E-222B63B1D815.png",
          "Screenshot_AE111D6A-15D7-4B35-A802-0E4481F6143F.png",
          "Screenshot_75352671-22A3-4DAF-BCFA-D0DFF5EBFE2C.png",
          "Screenshot_8752EB61-7EAB-4908-AD6D-A4973E40E9CB.png"
        ]
        expect(Snapshot::Collector.attachments_in_file('snapshot/spec/fixtures/Xcode-7_3-TestSummaries.plist')).to contain_exactly(*expected_files)
      end
    end
  end
end
