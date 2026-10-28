require 'fastlane_core/ui/github_issue_inspector_reporter'

describe Fastlane::InspectorReporter do
  describe "#inspector_successfully_received_report" do
    it "escapes every quote in the link to the remaining issues" do
      reporter = described_class.new
      report = double("report", issues: Array.new(4) { double("issue") }, total_results: 4, url: "https://github.com/search?q='a' 'b'")
      allow(reporter).to receive(:print_issue_full)
      allow(reporter).to receive(:print_open_link_hint)

      expect { reporter.inspector_successfully_received_report(report, double("inspector")) }.
        to output(%r{more at: https://github.com/search\?q=%27a%27 %27b%27\n}).to_stdout
    end
  end
end
