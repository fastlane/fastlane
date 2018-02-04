describe Fastlane do
  describe "Fastlane::TOOLS" do
    it "lists all the fastlane tools" do
      expect(Fastlane::TOOLS.count).to be >= 15
    end

    it "contains symbols for each of the tools" do
      Fastlane::TOOLS.each do |current|
        expect(current).to be_kind_of(Symbol)
      end
    end

    it "warns the user when a lane is called like a tool" do
      ff = Fastlane::FastFile.new('./fastlane/spec/fixtures/fastfiles/Fastfile1')
      expect(UI).to receive(:error).with("Lane name 'gym' should not be used because it is the name of a fastlane tool")
      expect(UI).to receive(:error).with("It is recommended to not use 'gym' as the name of your lane")
      ff.lane(:gym) do
      end
    end
  end
end
