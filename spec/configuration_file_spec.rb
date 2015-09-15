describe FastlaneCore do
  describe FastlaneCore::ConfigurationFile do
    describe "Properly loads and handles various configuration files" do
      let (:options) do
        [
          FastlaneCore::ConfigItem.new(key: :devices,
                                       description: "desc",
                                       is_string: false,
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :ios_version,
                                       description: "desc",
                                       default_value: "123"),
          FastlaneCore::ConfigItem.new(key: :app_identifier,
                                       description: "Mac",
                                       verify_block: proc do |value|
                                         raise "Invalid identifier '#{value}'" unless value.split('.').count == 3
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
        end.to raise_error "Invalid identifier 'such invalid'"
      end

      it "raises an exception if method is not available" do
        expect do
          config = FastlaneCore::Configuration.create(options, {})
          config.load_configuration_file("ConfigFileKeyNotHere")
        end.to raise_error (/Could not find option \'not_existent\' in the list of available options.*/)
      end

      it "overwrites existing values" do
        # Overwrite
        config = FastlaneCore::Configuration.create(options, { app_identifier: "detlef.app.super" })
        config.load_configuration_file('ConfigFileValid')
        expect(config[:app_identifier]).to eq("com.krausefx.app")

        # not overwrite
        config = FastlaneCore::Configuration.create(options, { app_identifier: "detlef.app.super" })
        config.load_configuration_file('ConfigFileEmpty')
        expect(config[:app_identifier]).to eq("detlef.app.super")
      end

      describe "Handling invalid broken configuration files" do
        it "properly shows an error message when the user uses invalid quotation" do
          config = FastlaneCore::Configuration.create(options, {})
          expect do
            config.load_configuration_file('./spec/fixtures/ConfigInvalidQuotation')
          end.to raise_error("Invalid quotation: You used the invalid quote ‘ instead of '. Make sure to use a good text editor like Sublime Text to edit your configuration file".red)
        end

        it "properly shows an error message when there is a syntax error in the Fastfile" do
          config = FastlaneCore::Configuration.create(options, {})
          expect do
            config.load_configuration_file('./spec/fixtures/ConfigSytnaxError')
          end.to raise_error(/Syntax error in your configuration file .* on line 15/)
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
            else raise 'no'
            end
          else raise 'no'
          end
        end)
      end
    end
  end
end
