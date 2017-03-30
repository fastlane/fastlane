describe FastlaneCore do
  describe FastlaneCore::ConfigItem do
    describe "ConfigItem input validation" do
      it "doesn't raise an error if everything's valid" do
        result = FastlaneCore::ConfigItem.new(key: :foo,
                                     short_option: "-f",
                                     description: "foo")
        expect(result.key).to eq(:foo)
        expect(result.short_option).to eq("-f")
        expect(result.description).to eq("foo")
      end

      describe "raises an error if short option is invalid" do
        it "long string" do
          expect do
            FastlaneCore::ConfigItem.new(key: :foo,
                                short_option: :f,
                                 description: "foo")
          end.to raise_error("short_option for key :foo must of type String")
        end

        it "long string" do
          expect do
            FastlaneCore::ConfigItem.new(key: :foo,
                                short_option: "-abc",
                                 description: "foo")
          end.to raise_error("short_option for key :foo must be a string of length 1")
        end
      end

      describe "raises an error for invalid description" do
        it "raises an error if the description ends with a dot" do
          expect do
            FastlaneCore::ConfigItem.new(key: :foo,
                                short_option: "-f",
                                 description: "foo.")
          end.to raise_error("Do not let descriptions end with a '.', since it's used for user inputs as well for key :foo")
        end
      end
    end
  end
end
