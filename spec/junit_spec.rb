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
        expect(path).to end_with("fastlane/report.xml")

        xml = Nokogiri::XML(File.open(path))
        expect(xml.xpath("//testcase")[0]["name"]).to eq("0: My Step Name")
        expect(xml.xpath("//testcase")[0]["time"]).to eq(time.to_s)
        expect(xml.xpath("//testcase")[1]["name"]).to eq("1: error step")
        expect(xml.xpath("//testcase")[1]["time"]).to eq(time.to_s)
        expect(xml.xpath("//failure")[0]["message"]).to eq("Some error text")

        File.delete(path)
      end
    end
  end
end
