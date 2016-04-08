describe FastlaneCore do
  describe FastlaneCore::XcodebuildListOutputParser do
    it "parses standard output" do
      output = %(
Information about project "SampleXcodeProject":
    Targets:
        SampleTarget1
        SampleTarget2

    Build Configurations:
        BuildConfiguration1
        BuildConfiguration2

    If no build configuration is specified and -scheme is not passed then "Release" is used.

    Schemes:
        SampleScheme1
        SampleScheme2: WithColumn
)
      parsed = FastlaneCore::XcodebuildListOutputParser.new(output)

      expect(parsed.targets).to eq(["SampleTarget1", "SampleTarget2"])
      expect(parsed.configurations).to eq(["BuildConfiguration1", "BuildConfiguration2"])
      expect(parsed.schemes).to eq(["SampleScheme1", "SampleScheme2: WithColumn"])
    end

    it "parses output with no schemes" do
      output = %(
There are no schemes in workspace
)
      parsed = FastlaneCore::XcodebuildListOutputParser.new(output)

      expect(parsed.targets).to eq([])
      expect(parsed.configurations).to eq([])
      expect(parsed.schemes).to eq([])
    end
  end
end
