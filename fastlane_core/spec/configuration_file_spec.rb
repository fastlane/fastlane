describe FastlaneCore do
  describe FastlaneCore::ConfigurationFile do
    describe "Properly loads and handles various configuration files" do
      let (:options) do
        [
          FastlaneCore::ConfigItem.new(key: :devices,
                                       description: "desc",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :a_boolean,
                                       description: "desc",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :another_boolean,
                                       description: "desc",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ios_version,
                                       description: "desc",
                                       default_value: "123"),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       description: "Mac",
                                       verify_block: proc do |value|
                                         UI.user_error!("Invalid identifier '#{value}'") unless value.split('.').count == 3
                                       end),
          FastlaneCore::ConfigItem.new(key: :apple_id,
                                       description: "yo",
                                       default_value: "123")
        ]
      end

      it "fills in the values from a valid config file" do
        config = FastlaneCore::Configuration.create(options, {})
        config.load_configuration_file('ConfigFileValid')
        expect(config[:app_identifier]).to eq("com.krausefx.app")
        expect(config[:apple_id]).to eq("from_le_block")
      end

      it "properly raises an exception if verify block doesn't match" do
        expect do
          config = FastlaneCore::Configuration.create(options, {})
          config.load_configuration_file("ConfigFileInvalidIdentifier")
        end.to raise_error("Invalid identifier 'such invalid'")
      end

      it "raises an exception if method is not available" do
        expect do
          config = FastlaneCore::Configuration.create(options, {})
          config.load_configuration_file("ConfigFileKeyNotHere")
        end.to raise_error(/Could not find option \'not_existent\' in the list of available options.*/)
      end

      it "overwrites existing values" do
        # not overwrite
        config = FastlaneCore::Configuration.create(options, { app_identifier: "detlef.app.super" })
        config.load_configuration_file('ConfigFileEmpty')
        expect(config[:app_identifier]).to eq("detlef.app.super")
      end

      it "properly loads boolean values" do
        config = FastlaneCore::Configuration.create(options, {})
        config.load_configuration_file('ConfigFileBooleanValues')
        expect(config[:a_boolean]).to be(false)
        expect(config[:another_boolean]).to be(true)
      end

      it "ignores the same item being set after the first time" do
        config = FastlaneCore::Configuration.create(options, {})
        config.load_configuration_file('ConfigFileRepeatedValueSet')
        expect(config[:app_identifier]).to eq('the.expected.value')
      end

      describe "Handling invalid broken configuration files" do
        it "automatically corrects invalid quotations" do
          config = FastlaneCore::Configuration.create(options, {})
          config.load_configuration_file('./fastlane_core/spec/fixtures/ConfigInvalidQuotation')
          # Not raising an error, even though we have invalid quotes
          expect(config[:app_identifier]).to eq("net.sunapps.1")
        end

        it "properly shows an error message when there is a syntax error in the Fastfile" do
          config = FastlaneCore::Configuration.create(options, {})
          expect do
            config.load_configuration_file('./fastlane_core/spec/fixtures/ConfigSytnaxError')
          end.to raise_error(/Syntax error in your configuration file .* on line 15/)
        end
      end

      describe "Prints out a table of summary" do
        it "shows a warning when no values were found" do
          expect(FastlaneCore::UI).to receive(:important).with("No values defined in './fastlane_core/spec/fixtures/ConfigFileEmpty'")

          config = FastlaneCore::Configuration.create(options, {})
          config.load_configuration_file('ConfigFileEmpty')
        end

        it "prints out a table of all the set values" do
          expect(Terminal::Table).to receive(:new).with({
            rows: [[:app_identifier, "com.krausefx.app"], [:apple_id, "from_le_block"]],
            title: "Detected Values from './fastlane_core/spec/fixtures/ConfigFileValid'"
          })

          config = FastlaneCore::Configuration.create(options, {})
          config.load_configuration_file('ConfigFileValid')
        end
      end

      it "allows using a custom block to handle special callbacks" do
        config = FastlaneCore::Configuration.create(options, {})
        config.load_configuration_file('ConfigFileUnhandledBlock', proc do |method_sym, arguments, block|
          if method_sym == :some_custom_block
            if arguments == ["parameter"]
              expect do
                block.call(arguments.first, "custom")
              end.to raise_error "Yeah: parameter custom"
            else UI.user_error!("no")
            end
          else UI.user_error!("no")
          end
        end)
      end
    end
  end
end
