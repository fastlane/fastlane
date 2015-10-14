describe Scan do
  describe Scan::TestResultParser do
    it "properly parses the xcodebuild output" do
      output = "\nExecuted 1 test, with 0 failures (0 unexpected) in 4.460 (4.461) seconds"

      result = Scan::TestResultParser.new.parse_result(output)
      expect(result).to eq({
          tests: "1",
          failures: "0",
          duration: "4.460"
      })
    end
  end
end
