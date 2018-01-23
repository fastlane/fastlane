describe Fastlane do
  describe Fastlane::FastFile do
    describe "OCLint Integration" do
      before :each do
        allow(FastlaneCore::FastlaneFolder).to receive(:path).and_return(nil)
      end

      it "raises an exception when the default compile_commands.json is not present" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            oclint
          end").runner.execute(:test)
        end.to raise_error("Could not find json compilation database at path 'compile_commands.json'")
      end

      it "works given the path to compile_commands.json" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint/compile_commands.json'
            )
          end").runner.execute(:test)

        expect(result).to match(%r{cd .* && oclint -report-type=html -o=oclint_report.html -p ./fastlane/spec/fixtures/oclint \".*})
      end

      it "works given a path to the directory containing compile_commands.json" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint'
            )
          end").runner.execute(:test)

        expect(result).to match(%r{cd .* && oclint -report-type=html -o=oclint_report.html -p ./fastlane/spec/fixtures/oclint \".*})
      end

      it "works with all parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint/compile_commands.json',
              select_regex: /.*/,
              exclude_regex: /Test.m/,
              report_type: 'pmd',
              report_path: 'report_path.xml',
              max_priority_1: 10,
              max_priority_2: 20,
              max_priority_3: 30,
              thresholds: ['LONG_LINE=200', 'LONG_METHOD=200'],
              enable_rules: ['DoubleNegative', 'DeadCode'],
              disable_rules: ['GotoStatement', 'ShortVariableName'],
              list_enabled_rules: true,
              enable_clang_static_analyzer: true,
              enable_global_analysis: true,
              allow_duplicated_violations: true
            )
          end").runner.execute(:test)

        expect(result).to include(' oclint -report-type=pmd -o=report_path.xml ')
        expect(result).to include(' -max-priority-1=10 ')
        expect(result).to include(' -max-priority-2=20 ')
        expect(result).to include(' -max-priority-3=30 ')
        expect(result).to include(' -rc=LONG_LINE=200 -rc=LONG_METHOD=200 ')
        expect(result).to include(' -rule DoubleNegative -rule DeadCode ')
        expect(result).to include(' -disable-rule GotoStatement -disable-rule ShortVariableName ')
        expect(result).to include(' -list-enabled-rules ')
        expect(result).to include(' -enable-clang-static-analyzer ')
        expect(result).to include(' -enable-global-analysis ')
        expect(result).to include(' -allow-duplicated-violations ')
      end

      it "works with single quote in rule name" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint/compile_commands.json',
              enable_rules: [\"CoveredSwitchStatementsDon'tNeedDefault\"],
              disable_rules: [\"CoveredSwitchStatementsDon'tNeedDefault\"]
            )
          end").runner.execute(:test)

        expect(result).to include(" -rule CoveredSwitchStatementsDon\\'tNeedDefault ")
        expect(result).to include(" -disable-rule CoveredSwitchStatementsDon\\'tNeedDefault ")
      end

      it "works with select regex" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint/compile_commands.json',
              select_regex: /AppDelegate/
            )
          end").runner.execute(:test)

        expect(result).to include('"fastlane/spec/fixtures/oclint/src/AppDelegate.m"')
      end

      it "works with select regex when regex is string" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint/compile_commands.json',
              select_regex: \"\/AppDelegate\"
            )
          end").runner.execute(:test)

        expect(result).to include('"fastlane/spec/fixtures/oclint/src/AppDelegate.m"')
      end

      it "works with exclude regex" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint/compile_commands.json',
              exclude_regex: /Test/
            )
          end").runner.execute(:test)

        expect(result).not_to(include('"fastlane/spec/fixtures/oclint/src/Test.m"'))
      end

      it "works with both select and exclude regex" do
        result = Fastlane::FastFile.new.parse("lane :test do
            oclint(
              compile_commands: './fastlane/spec/fixtures/oclint/compile_commands.json',
              select_regex: /\.*m/,
              exclude_regex: /Test/
            )
          end").runner.execute(:test)

        expect(result).to include('"fastlane/spec/fixtures/oclint/src/AppDelegate.m"')
        expect(result).not_to(include('Test'))
      end

      context 'with valid path to compile_commands.json' do
        context 'with no path to oclint' do
          let(:result) do
            Fastlane::FastFile.new.parse('lane :test do
              oclint( compile_commands: "./fastlane/spec/fixtures/oclint/compile_commands.json" )
            end').runner.execute(:test)
          end
          let(:command) { "cd #{File.expand_path('.').shellescape} && oclint -report-type=html -o=oclint_report.html" }

          it 'uses system wide oclint' do
            expect(result).to include(command)
          end
        end

        context 'with given path to oclint' do
          let(:result) do
            Fastlane::FastFile.new.parse('lane :test do
              oclint(
                compile_commands: "./fastlane/spec/fixtures/oclint/compile_commands.json",
                oclint_path: "test/bin/oclint"
              )
            end').runner.execute(:test)
          end
          let(:command) { "cd #{File.expand_path('.').shellescape} && test/bin/oclint -report-type=html -o=oclint_report.html" }

          it 'uses oclint provided' do
            expect(result).to include(command)
          end
        end
      end
    end
  end
end
