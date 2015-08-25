describe Fastlane do
  describe Fastlane::FastFile do
    describe "Gcovr Integration" do
      let(:file_utils) { class_double("FileUtils").as_stubbed_const }

      it "works with all parameters" do
        result = Fastlane::FastFile.new.parse("lane :test do
          gcovr({
            object_directory: 'object_directory_value',
            output: 'output_value',
            keep: true,
            delete: true,
            filter: 'filter_value',
            exclude: 'exclude_value',
            gcov_filter: 'gcov_filter_value',
            gcov_exclude: 'gcov_exclude_value',
            root: 'root_value',
            xml: true,
            xml_pretty: true,
            html: true,
            html_details: true,
            html_absolute_paths: true,
            branches: true,
            sort_uncovered: true,
            sort_percentage: true,
            gcov_executable: 'gcov_executable_value',
            exclude_unreachable_branches: true,
            use_gcov_files: true,
            print_summary: true
          })
        end").runner.execute(:test)

        expect(result).to eq("gcovr --object-directory \"object_directory_value\" -o \"output_value\" " \
          "-k -d -f \"filter_value\" -e \"exclude_value\" --gcov-filter \"gcov_filter_value\"" \
          " --gcov-exclude \"gcov_exclude_value\" -r \"root_value\" -x --xml-pretty --html --html-details" \
          " --html-absolute-paths -b -u -p --gcov-executable \"gcov_executable_value\" --exclude-unreachable-branches" \
          " -g -s")
      end

      context "output directory does not exist" do
        let(:output_dir) { "./code-coverage" }

        it "creates the output directory" do
          expect(file_utils).to receive(:mkpath).with(output_dir)

          Fastlane::FastFile.new.parse("lane :test do
            gcovr({
              output: '#{output_dir}/report.html'
            })
          end").runner.execute(:test)
        end
      end
    end
  end
end
