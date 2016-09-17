describe Fastlane do
  describe Fastlane::JUnitGenerator do
    describe "#generate" do
      it "properly generates a valid JUnit XML File" do
        time = 25

        results = [
          {
            name: "My Step Name",
            error: nil,
            time: time,
            started: Time.now - 100
          },
          {
            name: "error step",
            error: "Some error text",
            time: time,
            started: Time.now - 50
          }
        ]

        path = Fastlane::JUnitGenerator.generate(results)
        expect(path).to end_with("report.xml")

        content = File.read(path)
        expect(content).to include("0: My Step Name")
        expect(content).to include("1: error step")
        expect(content).to include("Some error text")

        File.delete(path)
      end
    end
  end
end
