describe Fastlane do
  describe Fastlane::LaneManagerBase do
    describe "#print_lane_context" do
      it "prints lane context" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = "test"

        cleaned_row_data = [[:LANE_NAME, "test"]]

        table_data = FastlaneCore::PrintTable.transform_output(cleaned_row_data)
        expect(FastlaneCore::PrintTable).to receive(:transform_output).with(cleaned_row_data).and_call_original
        expect(Terminal::Table).to receive(:new).with({
          title: "Lane Context".yellow,
          rows: table_data
        })
        Fastlane::LaneManagerBase.print_lane_context
      end

      it "doesn't crash when lane_context contains non unicode text" do
        Fastlane::Actions.lane_context[Fastlane::Actions::SharedValues::LANE_NAME] = "test\xAE"

        cleaned_row_data = [[:LANE_NAME, "test�"]]

        table_data = FastlaneCore::PrintTable.transform_output(cleaned_row_data)
        expect(FastlaneCore::PrintTable).to receive(:transform_output).with(cleaned_row_data).and_call_original
        expect(Terminal::Table).to receive(:new).with({
          title: "Lane Context".yellow,
          rows: table_data
        })
        Fastlane::LaneManagerBase.print_lane_context
      end
    end
  end
end
