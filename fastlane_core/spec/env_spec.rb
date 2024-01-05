describe FastlaneCore do
  describe FastlaneCore::Env do
    describe '#disabled/unset' do
      it "Reports false on disabled env" do
        FastlaneSpec::Env.with_env_values('FL_TEST_FALSE' => 'false', 'FL_TEST_ZERO' => '0', 'FL_TEST_OFF' => 'off', 'FL_TEST_NO' => 'no', 'FL_TEST_NIL' => nil) do
          expect(FastlaneCore::Env.truthy?('FL_TEST_FALSE')).to be_falsey
          expect(FastlaneCore::Env.truthy?('FL_TEST_ZERO')).to be_falsey
          expect(FastlaneCore::Env.truthy?('FL_TEST_OFF')).to be_falsey
          expect(FastlaneCore::Env.truthy?('FL_TEST_NO')).to be_falsey
          expect(FastlaneCore::Env.truthy?('FL_TEST_NOTSET')).to be_falsey
          expect(FastlaneCore::Env.truthy?('FL_TEST_NIL')).to be_falsey
        end
      end
      it "Reports true on enabled env" do
        FastlaneSpec::Env.with_env_values('FL_TEST_SET' => '1') do
          expect(FastlaneCore::Env.truthy?('FL_TEST_SET')).to be_truthy
        end
      end
    end
  end
end
