describe FastlaneCore do
  describe FastlaneCore::ConfigItem do
    describe "ConfigItem sensitivity testing" do
      it "is code_gen_sensitive if just sensitive" do
        item = FastlaneCore::ConfigItem.new(key: :tacos,
                                     short_option: "-t",
                                     description: "tacos are the best, amirite?",
                                     default_value: "taco secret",
                                     sensitive: true)
        expect(item.code_gen_sensitive).to be(true)
        expect(item.code_gen_default_value).to be(nil)
      end

      it "is not code_gen_sensitive by default" do
        item = FastlaneCore::ConfigItem.new(key: :tacos,
                                     short_option: "-t",
                                     default_value: "taco secret",
                                     description: "tacos are the best, amirite?")
        expect(item.code_gen_sensitive).to be(false)
        expect(item.code_gen_default_value).to eq("taco secret")
      end

      it "can be code_gen_sensitive even if not sensitive" do
        item = FastlaneCore::ConfigItem.new(key: :tacos,
                                     short_option: "-t",
                                     default_value: "taco secret",
                                     description: "tacos are the best, amirite?",
                                     code_gen_sensitive: true)
        expect(item.code_gen_sensitive).to be(true)
        expect(item.code_gen_default_value).to be(nil)
      end

      it "must be code_gen_sensitive even if defined false, when sensitive is true" do
        item = FastlaneCore::ConfigItem.new(key: :tacos,
                                     short_option: "-t",
                                     description: "tacos are the best, amirite?",
                                     sensitive: true,
                                     code_gen_sensitive: false)
        expect(item.code_gen_sensitive).to be(true)
        expect(item.sensitive).to be(true)
      end

      it "uses code_gen_default_value when default value exists" do
        item = FastlaneCore::ConfigItem.new(key: :tacos,
                                     short_option: "-t",
                                     default_value: "taco secret",
                                     code_gen_default_value: "nothing",
                                     description: "tacos are the best, amirite?",
                                     code_gen_sensitive: true)
        expect(item.code_gen_sensitive).to be(true)
        expect(item.code_gen_default_value).to eq("nothing")

        item = FastlaneCore::ConfigItem.new(key: :tacos,
                                     short_option: "-t",
                                     default_value: "taco secret",
                                     code_gen_default_value: "nothing",
                                     description: "tacos are the best, amirite?")
        expect(item.code_gen_sensitive).to be(false)
        expect(item.code_gen_default_value).to eq("nothing")

        # Don't override default value
        expect(item.default_value).to eq("taco secret")
      end
    end

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
