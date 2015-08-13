describe FastlaneCore do
  describe FastlaneCore::Configuration do
    describe "Create a new Configuration Manager" do

      it "raises an error if no hash is given" do
        expect {
          FastlaneCore::Configuration.create([], "string")
        }.to raise_error "values parameter must be a hash".red
      end

      it "raises an error if no array is given" do
        expect {
          FastlaneCore::Configuration.create("string", {})
        }.to raise_error "available_options parameter must be an array of ConfigItems but is String".red
      end

      it "raises an error if array contains invalid elements" do
        expect {
          FastlaneCore::Configuration.create(["string"], {})
        }.to raise_error "available_options parameter must be an array of ConfigItems. Found String.".red
      end


      it "raises an error if the option of a given value is not available" do
        expect {
          FastlaneCore::Configuration.create([], {cert_name: "value"})
        }.to raise_error "Could not find option 'cert_name' in the list of available options: ".red
      end

      it "raises an error if a description ends with a ." do
        expect {
          FastlaneCore::Configuration.create([FastlaneCore::ConfigItem.new(
                                         key: :cert_name, 
                                    env_name: "asdf",
                                 description: "Set the profile name.")], {})
        }.to raise_error "Do not let descriptions end with a '.', since it's used for user inputs as well".red
      end

      it "raises an error if a a key was used twice" do
        expect {
          FastlaneCore::Configuration.create([FastlaneCore::ConfigItem.new(
                                         key: :cert_name, 
                                    env_name: "asdf"), 
                                            FastlaneCore::ConfigItem.new(
                                         key: :cert_name, 
                                    env_name: "asdf")], {})
        }.to raise_error "Multiple entries for configuration key 'cert_name' found!".red
      end

      it "raises an error if a a short_option was used twice" do
        conflicting_options = [
          FastlaneCore::ConfigItem.new(key: :foo,
                                       short_option: "-f",
                                       description: "foo"),
          FastlaneCore::ConfigItem.new(key: :bar,
                                       short_option: "-f",
                                       description: "bar")
        ]
        expect {
          FastlaneCore::Configuration.create(conflicting_options, {})
        }.to raise_error "Multiple entries for short_option '-f' found!".red
      end

      it "verifies the default value as well" do
        c = FastlaneCore::ConfigItem.new(key: :output, 
                                  env_name: "SIGH_OUTPUT_PATH", 
                               description: "Directory in which the profile should be stored",
                             default_value: "notExistent",
                              verify_block: Proc.new do |value|
                                raise "Could not find output directory '#{value}'"
                              end)
        expect {
          @config = FastlaneCore::Configuration.create([c], {})
        }.to raise_error "Invalid default value for output, doesn't match verify_block".red
      end

      it "supports options without 'env_name'" do
        c = FastlaneCore::ConfigItem.new(key: :test, 
                               default_value: '123')
        config = FastlaneCore::Configuration.create([c], {})
        expect(config.values[:test]).to eq('123')
      end

      it "takes the values frmo the environment if available" do
        c = FastlaneCore::ConfigItem.new(key: :test, 
                                    env_name: "FL_TEST")
        config = FastlaneCore::Configuration.create([c], {})
        ENV["FL_TEST"] = "123value"
        expect(config.values[:test]).to eq('123value')
        ENV.delete("FL_TEST")
      end

      it "supports modifying the value after taken from the environment" do
        c = FastlaneCore::ConfigItem.new(key: :test, 
                                    env_name: "FL_TEST")
        config = FastlaneCore::Configuration.create([c], {})
        ENV["FL_TEST"] = "123value"
        config.values[:test].gsub!("123", "456")
        expect(config.values[:test]).to eq('456value')
        ENV.delete("FL_TEST")
      end

      describe "Use a valid Configuration Manager" do
        before do
          @options = [
            FastlaneCore::ConfigItem.new(key: :cert_name, 
                                    env_name: "SIGH_PROVISIONING_PROFILE_NAME", 
                                 description: "Set the profile name",
                               default_value: "production_default",
                                verify_block: nil),
            FastlaneCore::ConfigItem.new(key: :output, 
                                    env_name: "SIGH_OUTPUT_PATH", 
                                 description: "Directory in which the profile should be stored",
                               default_value: ".",
                                verify_block: Proc.new do |value|
                                  raise "Could not find output directory '#{value}'".red unless File.exists?(value)
                                end)
          ]
          @values = {
            cert_name: "asdf",
            output: ".."
          }
          @config = FastlaneCore::Configuration.create(@options, @values)
        end

        describe "#keys" do
          it "returns all available keys" do
            expect(@config.all_keys).to eq([:cert_name, :output])
          end
        end

        describe "#values" do
          it "returns the user values" do
            values = @config.values
            expect(values[:output]).to eq('..')
            expect(values[:cert_name]).to eq('asdf')
          end
          
          it "returns the default values" do
            @config = FastlaneCore::Configuration.create(@options, {}) # no user inputs
            values = @config.values
            expect(values[:cert_name]).to eq('production_default')
            expect(values[:output]).to eq('.')
          end
        end

        describe "fetch" do
          it "raises an error if a non symbol was given" do
            expect {
              @config.fetch(123)
            }.to raise_error "Key '123' must be a symbol. Example :app_id.".red
          end

          it "raises an error if this option does not exist" do
            expect {
              @config[:asdfasdf]
            }.to raise_error "Could not find option for key :asdfasdf. Available keys: cert_name, output".red
          end

          it "returns the value for the given key if given" do
            expect(@config.fetch(:cert_name)).to eq(@values[:cert_name])
          end

          it "returns the value for the given key if given using []" do
            expect(@config[:cert_name]).to eq(@values[:cert_name])
          end

          it "returns the default value if nothing else was given" do
            @config.set(:cert_name, nil)
            expect(@config[:cert_name]).to eq("production_default")
          end
        end

        describe "verify_block" do
          it "throws an error if the key doesn't exist" do
            expect {
              @config.set(:non_existing, "value")
            }.to raise_error("Could not find option 'non_existing' in the list of available options: cert_name, output".red)
          end

          it "throws an error if it's invalid" do
            expect {
              @config.set(:output, 132)
            }.to raise_error("'output' value must be a String! Found Fixnum instead.".red)
          end

          it "allows valid updates" do
            new_val = "../../"
            expect(@config.set(:output, new_val)).to eq(true)
            expect(@config[:output]).to eq(new_val)
          end
        end
      end
    end
  end
end