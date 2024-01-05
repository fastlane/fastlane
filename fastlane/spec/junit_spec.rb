describe Fastlane do
  describe Fastlane::JUnitGenerator do
    describe "#generate" do
      it "properly generates a valid JUnit XML File" do
        time = 25

        step = {
          name: "My Step Name",
          error: nil,
          time: time,
          started: Time.now - 100
        }
        error_step = {
          name: "error step",
          error: "Some error text",
          time: time,
          started: Time.now - 50
        }
        results = []
        99.times do
          results << step
        end
        results << error_step

        path = Fastlane::JUnitGenerator.generate(results)
        expect(path).to end_with("report.xml")

        content = File.read(path)
        expect(content).to include("00: My Step Name")
        expect(content).to include("98: My Step Name")
        expect(content).to include("99: error step")
        expect(content).to include("Some error text")

        File.delete(path)
      end
    end
  end
end
