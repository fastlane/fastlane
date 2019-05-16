describe Fastlane do
  describe Fastlane::FastFile do
    describe "prompt" do
      it "uses the CI value if necessary" do
        # make prompt think we're running in CI mode
        expect(FastlaneCore::UI).to receive(:interactive?).with(no_args).and_return(false)

        result = Fastlane::FastFile.new.parse("lane :test do
          prompt(text: 'text', ci_input: 'ci')
        end").runner.execute(:test)
        expect(result).to eq('ci')
      end

      it "reads full lines from $stdin until encountering multi_line_end_keyword" do
        # make prompt think we're running in interactive, non-CI mode
        expect(FastlaneCore::UI).to receive(:interactive?).with(no_args).and_return(true)

        expect($stdin).to receive(:gets).with(no_args).and_return("First line\n", "Second lineEND\n")
        result = Fastlane::FastFile.new.parse("lane :test do
          prompt(text: 'text', multi_line_end_keyword: 'END', ci_input: 'if this value is returned, prompt incorrectly assumes CI mode')
        end").runner.execute(:test)
        expect(result).to eq("First line\nSecond line")
      end
    end
  end
end
