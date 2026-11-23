describe Spaceship::Globals do
  describe ".env_truthy?" do
    it "is false when unset or set to a false value in any case" do
      FastlaneSpec::Env.with_env_values('FL_TEST_FALSE' => 'false', 'FL_TEST_ZERO' => '0', 'FL_TEST_OFF' => 'Off', 'FL_TEST_NO' => 'NO', 'FL_TEST_NIL' => nil) do
        %w(FL_TEST_FALSE FL_TEST_ZERO FL_TEST_OFF FL_TEST_NO FL_TEST_NIL FL_TEST_NOTSET).each do |name|
          expect(Spaceship::Globals.env_truthy?(name)).to eq(false), name
        end
      end
    end

    it "is true for any other value, empty included" do
      FastlaneSpec::Env.with_env_values('FL_TEST_SET' => '1', 'FL_TEST_EMPTY' => '') do
        expect(Spaceship::Globals.env_truthy?('FL_TEST_SET')).to eq(true)
        expect(Spaceship::Globals.env_truthy?('FL_TEST_EMPTY')).to eq(true)
      end
    end
  end
end
