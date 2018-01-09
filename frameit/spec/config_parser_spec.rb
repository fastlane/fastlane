describe Frameit do
  describe Frameit::ConfigParser do
    it "doesn't mind if there is no config file" do
      result = Frameit::ConfigParser.new.load("./invalid")
      expect(result).to eq(nil)
    end

    describe "Invalid JSON file" do
      it "raises an exception" do
        expect do
          Frameit::ConfigParser.new.parse("invalid_json")
        end.to raise_exception("Invalid JSON file at path ''. Make sure it's a valid JSON file")
      end
    end

    describe "Valid JSON file" do
      it "correctly parses and stores the data" do
        data = Frameit::ConfigParser.new.parse({
          default: {},
          data: []
        }.to_json)
      end

      it "let's the user access the stored data using both default and specific values" do
        default = {
          title: {
            font: "/",
            color: "#7F8081"
          },
          background: "./frameit/spec/fixtures/background.jpg"
        }
        specific = {
          filter: "filter",
          title: {
            font: "/tmp"
          }
        }

        config = Frameit::ConfigParser.new.parse({
          default: default,
          data: [
            specific
          ]
        }.to_json)

        expect(config.fetch_value("nothing")).to eq(JSON.parse(default.to_json)) # JSON.parse because of symbols != string

        expect(config.fetch_value("filter")).to eq(JSON.parse({
          title: {
            font: "/tmp",
            color: "#7F8081"
          },
          background: "./frameit/spec/fixtures/background.jpg",
          filter: "filter"
        }.to_json))
      end
    end
  end
end
