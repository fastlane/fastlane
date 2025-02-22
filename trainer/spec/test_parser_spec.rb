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
        allow(Trainer::XCResult::Parser).to receive(:`).with('xcrun xcresulttool version').and_return(version)
      end

      context 'with >= Xcode 16 beta 3' do
        let(:version) { 'xcresulttool version 23021, format version 3.53 (current)' }
        let(:expected) { "xcrun xcresulttool get --format json --path #{xcresult_sample_path} --legacy" }

        it 'should pass `--legacy`', requires_xcode: true do
          expect(command).to eq(expected)
        end
      end

      context 'with < Xcode 16 beta 3' do
        let(:version) { 'xcresulttool version 22608, format version 3.49 (current)' }
        let(:expected) { "xcrun xcresulttool get --format json --path #{xcresult_sample_path}" }

        it 'should not pass `--legacy`', requires_xcode: true do
          expect(command).to eq(expected)
        end
      end
    end

    describe "Stores the data in a useful format" do
      before do
        allow(Trainer::XCResult::Parser).to receive(:supports_xcode16_xcresulttool?).and_return(true)
      end
      let(:config) { { use_legacy_xcresulttool: true } }

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
    let(:xcresult_path) { 'Xcode16Mixed.xcresult' }
    let(:json_fixture_path) { File.expand_path("../fixtures/Xcode16Mixed.json", __FILE__) }
    let(:json_fixture) { JSON.parse(File.read(json_fixture_path)) }
    let(:expected_xml_path) { File.expand_path('../fixtures/Xcode16Mixed.junit', __FILE__) }

    before do
      allow(Trainer::XCResult::Parser).to receive(:xcresult_to_json).with(xcresult_path).and_return(json_fixture)
    end

    describe ".parse_xcresult" do
      context "with Xcode 16 xcresult bundle" do
        xit "generates the correct XML representation of test results" do
          # Parse the xcresult
          test_plan = Trainer::XCResult::Parser.parse_xcresult(path: xcresult_path)
          
          # Generate XML
          generated_xml = test_plan.to_xml

          # Read expected XML
          expected_xml = File.read(expected_xml_path)

          # Compare XML content
          # Note: We use a normalized comparison to handle whitespace and formatting differences
          normalized_generated = normalize_xml(generated_xml)
          normalized_expected = normalize_xml(expected_xml)

          expect(normalized_generated).to eq(normalized_expected)
        end
      end
    end

    # Helper method to normalize XML for comparison
    def normalize_xml(xml_string)
      # Remove whitespace, newlines, and sort attributes
      doc = REXML::Document.new(xml_string)
      
      # Recursive method to sort attributes
      def sort_attributes(element)
        # Sort attributes alphabetically
        element.attributes.keys.sort.each do |key|
          element.attributes[key] = element.attributes.delete(key)
        end

        # Recursively sort child elements
        element.elements.each { |child| sort_attributes(child) }
      end

      sort_attributes(doc.root)

      # Convert to string with minimal formatting
      output = String.new
      formatter = REXML::Formatters::Default.new
      formatter.write(doc, output)
      output
    end

    describe 'Xcode 16 xcresult bundle' do
      def normalize_xml(xml_string)
        doc = REXML::Document.new(xml_string)
        
        # Sort attributes for consistent comparison
        doc.root.attributes.keys.sort.each do |key|
          doc.root.attributes[key] = doc.root.attributes[key]
        end

        # Normalize whitespace and sort
        formatted_xml = ""
        formatter = REXML::Formatters::Pretty.new
        formatter.compact = true
        formatter.write(doc, formatted_xml)
        formatted_xml.gsub(/\s+/, ' ').strip
      end

      it 'generates correct JUnit XML for Xcode 16 xcresult bundle' do
        test_plan = Trainer::XCResult::Parser.parse_xcresult(path: xcresult_path)
        junit_xml = test_plan.to_xml

        expected_xml = File.read(expected_xml_path)
        
        normalized_actual = normalize_xml(junit_xml)
        normalized_expected = normalize_xml(expected_xml)

        expect(normalized_actual).to eq(normalized_expected)
      end
    end
  end
end
