describe Gym do
  before(:all) do
    options = { project: "./gym/examples/multipleSchemes/Example.xcodeproj" }
    @config = FastlaneCore::Configuration.create(Gym::Options.available_options, options)
    @project = FastlaneCore::Project.new(@config)

    @output = %(
2015-12-15 13:00:57.177 xcodebuild[81544:4350404] [MT] IDEDistribution: -[IDEDistributionLogging _createLoggingBundleAtPath:]: Created bundle at path '/var/folders/88/l77k840955j0x55fkb3m6cdr0000gn/T/EventLink_2015-12-15_13-00-57.177.xcdistributionlogs'.
2015-12-15 13:00:57.318 xcodebuild[81544:4350404] [MT] IDEDistribution: Failed to generate distribution items with error: Error Domain=DVTMachOErrorDomain Code=0 "Found an unexpected Mach-O header code: 0x72613c21" UserInfo={NSLocalizedDescription=Found an unexpected Mach-O header code: 0x72613c21, NSLocalizedRecoverySuggestion=}
2015-12-15 13:00:57.318 xcodebuild[81544:4350404] [MT] IDEDistribution: Step failed: <IDEDistributionSigningAssetsStep: 0x7f9d94cb55a0>: Error Domain=DVTMachOErrorDomain Code=0 "Found an unexpected Mach-O header code: 0x72613c21" UserInfo={NSLocalizedDescription=Found an unexpected Mach-O header code: 0x72613c21, NSLocalizedRecoverySuggestion=}
%)
  end

  describe Gym::ErrorHandler do
    before(:each) { Gym.config = @config }

    it "finds the standard output path" do
      expected = '/var/folders/88/l77k840955j0x55fkb3m6cdr0000gn/T/EventLink_2015-12-15_13-00-57.177.xcdistributionlogs/IDEDistribution.standard.log'
      expect(Gym::ErrorHandler.find_standard_output_path(@output)).to eq(expected)
    end

    it "raises build error with error_info" do
      expect(UI).to receive(:user_error!).with("Error building the application - see the log above", error_info: @output)
      Gym::ErrorHandler.handle_build_error(@output)
    end

    it "raises package error with error_info" do
      expect(UI).to receive(:user_error!).with("Error packaging up the application", error_info: @output)
      Gym::ErrorHandler.handle_package_error(@output)
    end
  end
end
