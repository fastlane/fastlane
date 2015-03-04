describe FastlaneCore do
  describe FastlaneCore::Configuration, now: true do
    describe "Create a new Configuration Manager" do

      it "raises an error if no hash is given" do
        expect {
          FastlaneCore::Configuration.create_manager([], "string")
        }.to raise_error "values parameter must be a hash".red
      end

      it "raises an error if no array is given" do
        expect {
          FastlaneCore::Configuration.create_manager("string", {})
        }.to raise_error "available_options parameter must be an array of ConfigItems".red
      end

      it "raises an error if array contains invalid elements" do
        expect {
          FastlaneCore::Configuration.create_manager(["string"], {})
        }.to raise_error "available_options parameter must be an array of ConfigItems".red
      end

      it "raises an error if the option of a given value is not available" do
        expect {
          FastlaneCore::Configuration.create_manager([], {cert_name: "value"})
        }.to raise_error "Could not find available option 'cert_name' in the list of available options ([])".red
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
                                  (value.kind_of?String and File.exists?(value))
                                end)
          ]
          @values = {
            cert_name: "asdf",
            output: ".."
          }
          @config = FastlaneCore::Configuration.create_manager(@options, @values)
        end

        describe "fetch" do
          it "raises an error if a non symbol was given" do
            expect {
              @config.fetch(123)
            }.to raise_error "Key '123' must be a symbol. Example :app_id.".red
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
            }.to raise_error("Could not find available option 'non_existing' in the list of !available options ([:cert_name, :output])".red)
          end

          it "throws an error if it's invalid" do
            expect {
              @config.set(:output, 132)
            }.to raise_error("Invalid value '132' for option 'output: Directory in which the profile should be stored'".red)
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