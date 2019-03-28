describe FastlaneSpec::Env do
  # rubocop:disable Style/VariableName
  describe '#with_ARGV' do
    it 'temporarily overrides the ARGV values under normal usage' do
      current_ARGV = ARGV.dup
      temp_ARGV = %w[temp_inside]
      block_ARGV = nil
      FastlaneSpec::Env.with_ARGV(temp_ARGV) { block_ARGV = ARGV.dup }
      expect(block_ARGV).to eq(temp_ARGV)
      expect(ARGV).to eq(current_ARGV)
    end

    it 'restores ARGV values even if fails in block' do
      current_ARGV = ARGV.dup
      begin
        FastlaneSpec::Env.with_ARGV(%w[temp_inside]) { raise 'BOU' }
        fail('should not reach here')
      rescue StandardError

      end
      expect(ARGV).to eq(current_ARGV)
    end

    it 'sets ARGV for good if no block is given' do
      current_ARGV = ARGV.dup
      new_ARGV = %w[forever]
      FastlaneSpec::Env.with_ARGV(new_ARGV)
      expect(ARGV).to eq(new_ARGV)
      # reset...
      FastlaneSpec::Env.with_ARGV(current_ARGV)
      expect(ARGV).to eq(current_ARGV)
    end
  end
  # rubocop:enable Style/VariableName
end
