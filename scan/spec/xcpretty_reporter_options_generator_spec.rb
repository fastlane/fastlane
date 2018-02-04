describe Scan do
  describe Scan::XCPrettyReporterOptionsGenerator, requires_xcodebuild: true do
    before(:all) do
      options = { project: "./scan/examples/standard/app.xcodeproj" }
      Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
      Scan.cache[:temp_junit_report] = nil
    end

    describe "xcpretty reporter options generation" do
      it "generates options for the junit tempfile report required by scan" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "html", "report.html", "/test_output", false)
        reporter_options = generator.generate_reporter_options
        temp_junit_report = Scan.cache[:temp_junit_report]

        expect(temp_junit_report).not_to(be_nil)
        expect(reporter_options).to end_with([
                                               "--report junit",
                                               "--output '#{temp_junit_report}'"
                                             ])
      end

      it "generates options for a custom junit report with default file name" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "junit", nil, "/test_output", false)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report junit",
                                                 "--output '/test_output/report.junit'"
                                               ])
      end

      it "generates options for a custom junit report with custom file name" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "junit", "junit.xml", "/test_output", false)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report junit",
                                                 "--output '/test_output/junit.xml'"
                                               ])
      end

      it "generates options for a custom html report with default file name" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "html", nil, "/test_output", false)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report html",
                                                 "--output '/test_output/report.html'"
                                               ])
      end

      it "generates options for a custom html report with custom file name" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "html", "custom_report.html", "/test_output", false)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report html",
                                                 "--output '/test_output/custom_report.html'"
                                               ])
      end

      it "generates options for a custom json-compilation-database file with default file name" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "json-compilation-database", nil, "/test_output", false)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report json-compilation-database",
                                                 "--output '/test_output/report.json-compilation-database'"
                                               ])
      end

      it "generates options for a custom json-compilation-database file with a custom file name" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "json-compilation-database", "custom_report.json", "/test_output", false)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report json-compilation-database",
                                                 "--output '/test_output/custom_report.json'"
                                               ])
      end

      it "generates options for a custom json-compilation-database file with a clang naming convention" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "json-compilation-database", "ignore_custom_name_here.json", "/test_output", true)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report json-compilation-database",
                                                 "--output '/test_output/compile_commands.json'"
                                               ])
      end

      it "generates options for a multiple reports with default file names" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "html,junit", nil, "/test_output", true)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report html",
                                                 "--output '/test_output/report.html'",
                                                 "--report junit",
                                                 "--output '/test_output/report.junit'"
                                               ])
      end

      it "generates options for a multiple reports with default file names" do
        generator = Scan::XCPrettyReporterOptionsGenerator.new(false, "html,junit", "custom_report.html,junit.xml", "/test_output", true)
        reporter_options = generator.generate_reporter_options

        expect(reporter_options).to start_with([
                                                 "--report html",
                                                 "--output '/test_output/custom_report.html'",
                                                 "--report junit",
                                                 "--output '/test_output/junit.xml'"
                                               ])
      end

      context "options passed as arrays" do
        it "generates options for the junit tempfile report required by scan" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["html"], ["report.html"], "test_output", false)
          reporter_options = generator.generate_reporter_options
          temp_junit_report = Scan.cache[:temp_junit_report]

          expect(temp_junit_report).not_to(be_nil)
          expect(reporter_options).to end_with([
                                                 "--report junit",
                                                 "--output '#{temp_junit_report}'"
                                               ])
        end

        it "generates options for a custom junit report with default file name" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["junit"], nil, "/test_output", false)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report junit",
                                                   "--output '/test_output/report.junit'"
                                                 ])
        end

        it "generates options for a custom junit report with custom file name" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["junit"], ["junit.xml"], "/test_output", false)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report junit",
                                                   "--output '/test_output/junit.xml'"
                                                 ])
        end

        it "generates options for a custom html report with default file name" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["html"], nil, "/test_output", false)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report html",
                                                   "--output '/test_output/report.html'"
                                                 ])
        end

        it "generates options for a custom html report with custom file name" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["html"], ["custom_report.html"], "/test_output", false)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report html",
                                                   "--output '/test_output/custom_report.html'"
                                                 ])
        end

        it "generates options for a custom json-compilation-database file with default file name" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["json-compilation-database"], nil, "/test_output", false)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report json-compilation-database",
                                                   "--output '/test_output/report.json-compilation-database'"
                                                 ])
        end

        it "generates options for a custom json-compilation-database file with a custom file name" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["json-compilation-database"], ["custom_report.json"], "/test_output", false)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report json-compilation-database",
                                                   "--output '/test_output/custom_report.json'"
                                                 ])
        end

        it "generates options for a custom json-compilation-database file with a clang naming convention" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["json-compilation-database"], ["ignore_custom_name_here.json"], "/test_output", true)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to include("--report json-compilation-database")
          expect(reporter_options).to include("--output '/test_output/compile_commands.json'")

          expect(reporter_options).to start_with([
                                                   "--report json-compilation-database",
                                                   "--output '/test_output/compile_commands.json'"
                                                 ])
        end

        it "generates options for a multiple reports with default file names" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["html", "junit"], nil, "/test_output", true)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report html",
                                                   "--output '/test_output/report.html'",
                                                   "--report junit",
                                                   "--output '/test_output/report.junit'"
                                                 ])
        end

        it "generates options for a multiple reports with custom file names" do
          generator = Scan::XCPrettyReporterOptionsGenerator.new(false, ["html", "junit"], ["custom_report.html", "junit.xml"], "/test_output", true)
          reporter_options = generator.generate_reporter_options

          expect(reporter_options).to start_with([
                                                   "--report html",
                                                   "--output '/test_output/custom_report.html'",
                                                   "--report junit",
                                                   "--output '/test_output/junit.xml'"
                                                 ])
        end
      end

      context "generator created from Scan.config" do
        it "generates options for a single reports while using custom_report_file_name" do
          options = {
            project: "./scan/examples/standard/app.xcodeproj",
            output_types: "junit,html",
            output_files: "junit.xml",
            output_directory: "/test_output"
          }

          Scan.config = FastlaneCore::Configuration.create(Scan::Options.available_options, options)
          Scan.cache[:temp_junit_report] = nil

          expect(FastlaneCore::UI).to receive(:important).with("WARNING: output_types and output_files do not have the same number of items. Default values will be substituted as needed.")

          reporter_options = Scan::XCPrettyReporterOptionsGenerator.generate_from_scan_config.generate_reporter_options
          expect(reporter_options).to eq([
                                           "--report junit",
                                           "--output '/test_output/junit.xml'",
                                           "--report html",
                                           "--output '/test_output/report.html'",
                                           "--report junit",
                                           "--output '#{Scan.cache[:temp_junit_report]}'"
                                         ])
        end
      end
    end
  end
end
