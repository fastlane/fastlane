describe Trainer do
  describe Trainer::TestParser do
    describe "Loading a file" do
      it "raises an error if the file doesn't exist" do
        expect do
          Trainer::TestParser.new("notExistent")
        end.to raise_error(/File not found at path/)
      end

      it "raises an error if FormatVersion is not supported" do
        expect do
          Trainer::TestParser.new("./trainer/spec/fixtures/InvalidVersionMismatch.plist")
        end.to raise_error("Format version '0.9' is not supported, must be 1.1, 1.2")
      end

      it "loads a file without throwing an error" do
        Trainer::TestParser.new("./trainer/spec/fixtures/Valid1.plist")
      end
    end

    describe "#auto_convert" do
      it "raises an error if no files were found" do
        expect do
          Trainer::TestParser.auto_convert({ path: "bin" })
        end.to raise_error("No test result files found in directory 'bin', make sure the file name ends with 'TestSummaries.plist' or '.xcresult'")
      end
    end

    describe "#generate_cmd_parse_xcresult" do
      let(:xcresult_sample_path) { "./trainer/spec/fixtures/Test.test_result.xcresult" }
      let(:command) { Trainer::LegacyXCResult::Parser.send(:generate_cmd_parse_xcresult, xcresult_sample_path) }

      before do
        allow(File).to receive(:expand_path).with(xcresult_sample_path).and_return(xcresult_sample_path)
        allow(Trainer::XCResult::Helper).to receive(:`).with('xcrun xcresulttool version').and_return(version)
      end

      context 'with >= Xcode 16 beta 3' do
        let(:version) { 'xcresulttool version 23021, format version 3.53 (current)' }
        let(:expected) { ['xcrun', 'xcresulttool', 'get', '--format', 'json', '--path', xcresult_sample_path, '--legacy'] }

        it 'should pass `--legacy`', requires_xcode: true do
          expect(command).to eq(expected)
        end
      end

      context 'with < Xcode 16 beta 3' do
        let(:version) { 'xcresulttool version 22608, format version 3.49 (current)' }
        let(:expected) { ['xcrun', 'xcresulttool', 'get', '--format', 'json', '--path', xcresult_sample_path] }

        it 'should not pass `--legacy`', requires_xcode: true do
          expect(command).to eq(expected)
        end
      end
    end

    describe "Stores the data in a useful format" do
      let(:config) { { force_legacy_xcresulttool: true } }

      describe "#tests_successful?" do
        it "returns false if tests failed" do
          tp = Trainer::TestParser.new("./trainer/spec/fixtures/Valid1.plist", config)
          expect(tp.tests_successful?).to eq(false)
        end
      end

      it "works as expected with plist" do
        tp = Trainer::TestParser.new("./trainer/spec/fixtures/Valid1.plist")
        expect(tp.data).to eq([
                                {
                                  project_path: "Trainer.xcodeproj",
                                  target_name: "Unit",
                                  test_name: "Unit",
                                  duration: 0.4,
                                  tests: [
                                    {
                                      identifier: "Unit/testExample()",
                                      test_group: "Unit",
                                      name: "testExample()",
                                      object_class: "IDESchemeActionTestSummary",
                                      status: "Success",
                                      guid: "6840EEB8-3D7A-4B2D-9A45-6955DC11D32B",
                                      duration: 0.1
                                    },
                                    {
                                      identifier: "Unit/testExample2()",
                                      test_group: "Unit",
                                      name: "testExample2()",
                                      object_class: "IDESchemeActionTestSummary",
                                      status: "Failure",
                                      guid: "B2EB311E-ED8D-4DAD-8AF0-A455A20855DF",
                                      duration: 0.1,
                                      failures: [
                                        {
                                          file_name: "/Users/liamnichols/Code/Local/Trainer/Unit/Unit.swift",
                                          line_number: 19,
                                          message: "XCTAssertTrue failed - ",
                                          performance_failure: false,
                                          failure_message: "XCTAssertTrue failed -  (/Users/liamnichols/Code/Local/Trainer/Unit/Unit.swift:19)"
                                        }
                                      ]
                                    },
                                    {
                                      identifier: "Unit/testPerformanceExample()",
                                      test_group: "Unit",
                                      name: "testPerformanceExample()",
                                      object_class: "IDESchemeActionTestSummary",
                                      status: "Success",
                                      guid: "72D0B210-939D-4751-966F-986B6CB2660C",
                                      duration: 0.2
                                    }
                                  ],
                                  number_of_tests: 3,
                                  number_of_failures: 1,
                                  number_of_tests_excluding_retries: 3,
                                  number_of_failures_excluding_retries: 1,
                                  number_of_retries: 0
                                }
                              ])
      end

      it "works as expected with xcresult", requires_xcode: true do
        tp = Trainer::TestParser.new("./trainer/spec/fixtures/Test.test_result.xcresult", config)
        expect(tp.data).to eq([
                                {
                                  project_path: "Test.xcodeproj",
                                  target_name: "TestUITests",
                                  test_name: "TestUITests",
                                  configuration_name: "Test Scheme Action",
                                  duration: 16.05245804786682,
                                  tests: [
                                    {
                                      identifier: "TestUITests.testExample()",
                                      name: "testExample()",
                                      duration: 16.05245804786682,
                                      status: "Success",
                                      test_group: "TestUITests",
                                      guid: ""
                                    }
                                  ],
                                  number_of_tests: 1,
                                  number_of_failures: 0,
                                  number_of_skipped: 0,
                                  number_of_tests_excluding_retries: 1,
                                  number_of_failures_excluding_retries: 0,
                                  number_of_retries: 0
                                },
                                {
                                  project_path: "Test.xcodeproj",
                                  target_name: "TestThisDude",
                                  test_name: "TestThisDude",
                                  configuration_name: "Test Scheme Action",
                                  duration: 0.5279300212860107,
                                  tests: [
                                    {
                                      identifier: "TestTests.testExample()",
                                      name: "testExample()",
                                      duration: 0.0005381107330322266,
                                      status: "Success",
                                      test_group: "TestTests",
                                      guid: ""
                                    },
                                    {
                                      identifier: "TestTests.testFailureJosh1()",
                                      name: "testFailureJosh1()",
                                      duration: 0.006072044372558594,
                                      status: "Failure",
                                      test_group: "TestTests",
                                      guid: "",
                                      failures: [
                                        {
                                          file_name: "",
                                          line_number: 0,
                                          message: "",
                                          performance_failure: {},
                                          failure_message: "XCTAssertTrue failed (/Users/josh/Projects/fastlane/test-ios/TestTests/TestTests.swift#CharacterRangeLen=0&EndingLineNumber=36&StartingLineNumber=36)"
                                          }
                                      ]
                                    },
                                    {
                                      identifier: "TestTests.testPerformanceExample()",
                                      name: "testPerformanceExample()",
                                      duration: 0.2661939859390259,
                                      status: "Success",
                                      test_group: "TestTests",
                                      guid: ""
                                    },
                                    {
                                      identifier: "TestThisDude.testExample()",
                                      name: "testExample()",
                                      duration: 0.0004099607467651367,
                                      status: "Success",
                                      test_group: "TestThisDude",
                                      guid: ""
                                    },
                                    {
                                      identifier: "TestThisDude.testFailureJosh2()",
                                      name: "testFailureJosh2()",
                                      duration: 0.001544952392578125,
                                      status: "Failure",
                                      test_group: "TestThisDude",
                                      guid: "",
                                      failures: [
                                        {
                                          file_name: "",
                                          line_number: 0,
                                          message: "",
                                          performance_failure: {},
                                          failure_message: "XCTAssertTrue failed (/Users/josh/Projects/fastlane/test-ios/TestThisDude/TestThisDude.swift#CharacterRangeLen=0&EndingLineNumber=35&StartingLineNumber=35)"
                                        }
                                      ]
                                    },
                                    {
                                      identifier: "TestThisDude.testPerformanceExample()",
                                      name: "testPerformanceExample()",
                                      duration: 0.2531709671020508,
                                      status: "Success",
                                      test_group: "TestThisDude",
                                      guid: ""
                                    }
                                  ],
                                  number_of_tests: 6,
                                  number_of_failures: 2,
                                  number_of_skipped: 0,
                                  number_of_tests_excluding_retries: 6,
                                  number_of_failures_excluding_retries: 2,
                                  number_of_retries: 0
                                }
                              ])
      end

      it "still produces a test failure message when file url is missing", requires_xcode: true do
        allow_any_instance_of(Trainer::LegacyXCResult::TestFailureIssueSummary).to receive(:document_location_in_creating_workspace).and_return(nil)
        tp = Trainer::TestParser.new("./trainer/spec/fixtures/Test.test_result.xcresult", config)
        test_failures = tp.data.last[:tests].select { |t| t[:failures] }
        failure_messages = test_failures.map { |tf| tf[:failures].first[:failure_message] }
        expect(failure_messages).to eq(["XCTAssertTrue failed", "XCTAssertTrue failed"])
        RSpec::Mocks.space.proxy_for(Trainer::LegacyXCResult::TestFailureIssueSummary).reset
      end

      it "works as expected with xcresult with spaces", requires_xcode: true do
        tp = Trainer::TestParser.new("./trainer/spec/fixtures/Test.with_spaces.xcresult", config)
        expect(tp.data).to eq([
                                {
                                  project_path: "SpaceTests.xcodeproj",
                                  target_name: "SpaceTestsTests",
                                  test_name: "SpaceTestsTests",
                                  configuration_name: "Test Scheme Action",
                                  duration: 0.21180307865142822,
                                  tests: [
                                    {
                                      identifier: "SpaceTestsSpec.a test with spaces, should always fail()",
                                      name: "a test with spaces, should always fail()",
                                      duration: 0.21180307865142822,
                                      status: "Failure",
                                      test_group: "SpaceTestsSpec",
                                      guid: "",
                                      failures: [
                                        {
                                          failure_message: "expected to equal <1>, got <2>\n (/Users/mahmood.tahir/Developer/SpaceTests/SpaceTestsTests/TestSpec.swift#CharacterRangeLen=0&EndingLineNumber=15&StartingLineNumber=15)",
                                          file_name: "",
                                          line_number: 0,
                                          message: "",
                                          performance_failure: {}
                                        }
                                      ]
                                    }
                                  ],
                                  number_of_tests: 1,
                                  number_of_failures: 1,
                                  number_of_skipped: 0,
                                  number_of_tests_excluding_retries: 1,
                                  number_of_failures_excluding_retries: 1,
                                  number_of_retries: 0
                                }
                              ])
      end
    end
  end

  describe Trainer::XCResult::Parser do
    it 'generates same data for legacy and new commands', requires_xcodebuild: true do
      skip "Requires Xcode 16 or higher" unless Trainer::XCResult::Helper.supports_xcode16_xcresulttool?

      xcresult_path = File.expand_path('../fixtures/Test.test_result.xcresult', __FILE__)

      keys_to_compare = [
        :number_of_tests,
        :number_of_failures,
        :number_of_tests_excluding_retries,
        :number_of_failures_excluding_retries,
        :number_of_retries,
        :number_of_skipped
      ]

      new_parser_data = Trainer::XCResult::Parser.parse_xcresult(path: xcresult_path).map do |hash|
        hash.slice(*keys_to_compare)
      end

      legacy_parser_data = Trainer::LegacyXCResult::Parser.parse_xcresult(path: xcresult_path).map do |hash|
        hash.slice(*keys_to_compare)
      end

      expect(legacy_parser_data).to eq(new_parser_data)
    end

    describe 'Xcode 16 xcresult bundle' do
      let(:xcresult_path) { File.expand_path('../fixtures/Xcode16-Mixed-XCTest-SwiftTesting.xcresult', __FILE__) }
      let(:json_fixture_path) { File.expand_path("../fixtures/Xcode16-Mixed-XCTest-SwiftTesting.json", __FILE__) }
      let(:json_fixture) { JSON.parse(File.read(json_fixture_path)) }

      it 'generates correct JUnit XML including retries', requires_xcodebuild: true do
        skip "Requires Xcode 16 or higher" unless Trainer::XCResult::Helper.supports_xcode16_xcresulttool?

        # Uncomment this if you want to bypass the xcresult_to_json call during testing
        # allow(Trainer::XCResult::Parser).to receive(:xcresult_to_json).with(xcresult_path).and_return(json_fixture)

        test_plan = Trainer::XCResult::Parser.parse_xcresult(path: xcresult_path)
        junit_xml = test_plan.to_xml

        expected_xml_path = File.expand_path('../fixtures/Xcode16-Mixed-XCTest-SwiftTesting-WithRetries.junit', __FILE__)
        expected_xml = File.read(expected_xml_path)
        expect(junit_xml.chomp).to eq(expected_xml.chomp)
      end

      it 'generates correct JUnit XML excluding retries', requires_xcodebuild: true do
        skip "Requires Xcode 16 or higher" unless Trainer::XCResult::Helper.supports_xcode16_xcresulttool?

        # Uncomment this if you want to bypass the xcresult_to_json call during testing
        # allow(Trainer::XCResult::Parser).to receive(:xcresult_to_json).with(xcresult_path).and_return(json_fixture)

        test_plan = Trainer::XCResult::Parser.parse_xcresult(path: xcresult_path, output_remove_retry_attempts: true)
        junit_xml = test_plan.to_xml
        expected_xml_path = File.expand_path('../fixtures/Xcode16-Mixed-XCTest-SwiftTesting-WithoutRetries.junit', __FILE__)
        expected_xml = File.read(expected_xml_path)
        expect(junit_xml.chomp).to eq(expected_xml.chomp)
      end
    end
  end
end
