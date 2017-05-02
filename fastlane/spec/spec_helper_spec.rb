describe FastlaneSpec::Env do
  # rubocop:disable Style/VariableName
  describe "#with_ARGV" do
    it "temporarily overrides the ARGV values under normal usage" do
      current_ARGV = ARGV.dup
      temp_ARGV = ['temp_inside']
      block_ARGV = nil
      FastlaneSpec::Env.with_ARGV(temp_ARGV) do
        block_ARGV = ARGV.dup
      end
      expect(block_ARGV).to eq(temp_ARGV)
      expect(ARGV).to eq(current_ARGV)
    end

    it "restores ARGV values even if fails in block" do
      current_ARGV = ARGV.dup
      begin
        FastlaneSpec::Env.with_ARGV(['temp_inside']) do
          raise "BOU"
        end
        fail("should not reach here")
      rescue
      end
      expect(ARGV).to eq(current_ARGV)
    end

    it "sets ARGV for good if no block is given" do
      current_ARGV = ARGV.dup
      new_ARGV = ['forever']
      FastlaneSpec::Env.with_ARGV(new_ARGV)
      expect(ARGV).to eq(new_ARGV)
      # reset...
      FastlaneSpec::Env.with_ARGV(current_ARGV)
      expect(ARGV).to eq(current_ARGV)
    end
  end
  # rubocop:enable Style/VariableName
end
