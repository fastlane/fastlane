describe Match::Options do
  describe "storage plugins" do
    let(:plugin_storage) do
      Class.new(Match::Storage::Interface) do
        def self.configure(params)
          new
        end
      end
    end

    let(:plugin_option) do
      FastlaneCore::ConfigItem.new(key: :test_plugin_bucket,
                                   description: "Bucket of the test storage plugin",
                                   optional: true)
    end

    after do
      Match::Storage.backends.delete("test_plugin")
      Match::Options.appended_options.delete(plugin_option)
    end

    it "accepts a registered storage backend as storage_mode" do
      Match::Storage.register_backend(type: "test_plugin", storage_class: plugin_storage)

      config = FastlaneCore::Configuration.create(Match::Options.available_options, { storage_mode: "test_plugin" })

      expect(Match.storage_modes).to eq(%w(git google_cloud s3 gitlab_secure_files test_plugin))
      expect(Match::Storage.from_params(config)).to be_a(plugin_storage)
    end

    it "accepts an appended option" do
      Match::Options.append_option(plugin_option)

      config = FastlaneCore::Configuration.create(Match::Options.available_options, { test_plugin_bucket: "a-bucket" })

      expect(config[:test_plugin_bucket]).to eq("a-bucket")
      expect(Match::Options.available_options.count { |option| option.key == :test_plugin_bucket }).to eq(1)
    end

    it "reads Appfile defaults each time it builds the options" do
      Match::Options.append_option(plugin_option)
      allow(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).and_return(nil)

      FastlaneSpec::Env.with_env_values("MATCH_USERNAME" => nil) do
        allow(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).with(:apple_id).and_return("first@example.com")
        first = FastlaneCore::Configuration.create(Match::Options.available_options, {})
        allow(CredentialsManager::AppfileConfig).to receive(:try_fetch_value).with(:apple_id).and_return("second@example.com")
        second = FastlaneCore::Configuration.create(Match::Options.available_options, {})

        expect(first[:username]).to eq("first@example.com")
        expect(second[:username]).to eq("second@example.com")
      end
    end

    it "also appends to a list a plugin memoized before the option was appended" do
      memoized = Match::Options.available_options
      Match::Options.instance_variable_set(:@available_options, memoized)

      Match::Options.append_option(plugin_option)

      expect(memoized.count(plugin_option)).to eq(1)
      expect(Match::Options.available_options.count(plugin_option)).to eq(1)
    ensure
      Match::Options.remove_instance_variable(:@available_options)
    end
  end
end
