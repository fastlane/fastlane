describe IosDeployKit, now: true do
  describe IosDeployKit::Deliverfile::Deliverfile do

    describe "#initialize" do
      it "raises an error when file was not found" do
        expect {
          IosDeployKit::Deliverfile::Deliverfile.new
        }.to raise_exception "Deliverfile not found at path './Deliverfile'"
      end

      it "successfully loads the Deliverfile if it's there" do
        file = IosDeployKit::Deliverfile::Deliverfile.new("./spec/fixtures/Deliverfiles/Deliverfile1")
      end
    end
  end
end