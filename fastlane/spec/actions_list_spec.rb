require 'fastlane/documentation/actions_list'

describe Fastlane do
  describe "Action List" do
    it "doesn't throw an exception" do
      Fastlane::ActionsList.run(filter: nil)
    end

    it "doesn't throw an exception with filter" do
      Fastlane::ActionsList.run(filter: 'deliver')
    end

    it "shows all available actions if action can't be found" do
      Fastlane::ActionsList.run(filter: 'nonExistingHere')
    end

    it "returns all available actions with the type `Class`" do
      actions = []
      Fastlane::ActionsList.all_actions do |a|
        actions << a
        expect(a.class).to eq(Class)
      end
      expect(actions.count).to be > 80
    end

    it "allows filtering of the platforms" do
      count = 0
      Fastlane::ActionsList.all_actions("nothing special") { count += 1 }
      expect(count).to be > 40
      expect(count).to be < 120
    end

    describe "Provide action details" do
      Fastlane::ActionsList.all_actions do |action, name|
        it "Shows the details for action '#{name}'" do
          Fastlane::ActionsList.show_details(filter: name)
        end
      end
    end

    describe "JSON" do
      let(:example_action) do
        Class.new(Fastlane::Action) do
          def self.description
            "Example action"
          end

          def self.category
            :misc
          end

          def self.is_supported?(platform)
            platform == :android
          end

          def self.available_options
            [
              FastlaneCore::ConfigItem.new(key: :path, description: "Path", env_name: "EXAMPLE_PATH", default_value: "./out"),
              FastlaneCore::ConfigItem.new(key: :count, description: "Count", type: Integer, short_option: "-c", optional: true),
              FastlaneCore::ConfigItem.new(key: :user, description: "User", default_value: "local value", default_value_dynamic: true),
              FastlaneCore::ConfigItem.new(key: :token, description: "Token", sensitive: true, default_value: "secret value"),
              FastlaneCore::ConfigItem.new(key: :callback, description: "Callback", type: :string_callback, optional: true),
              FastlaneCore::ConfigItem.new(key: :flag, description: "Flag", is_string: false, default_value: false), # rubocop:disable Lint/IsStringUsage -- an untyped option, as pilot's skip_submission
              FastlaneCore::ConfigItem.new(key: :old, description: "Old", optional: true, deprecated: "Use path"),
              FastlaneCore::ConfigItem.new(key: :older, description: "Older", optional: true, deprecated: true),
              ['legacy', 'A legacy option']
            ]
          end

          def self.output
            [['EXAMPLE_OUTPUT', 'The output']]
          end

          def self.return_type
            :string
          end
        end
      end

      before do
        stub_const("Fastlane::Actions::JsonExampleAction", example_action)
      end

      it "lists every action with a summary, and none fails" do
        # The broken_action fixture, which other examples require, is not an action and stays defined once loaded
        hide_const("Fastlane::Actions::BrokenAction")
        json = Fastlane::ActionsList.generate_json

        expect(json[:version]).to eq(1)
        expect(json[:actions]["json_example"]).to eq({ description: "Example action", category: :misc, platforms: [:android], deprecated: false })
        expect(json[:actions].select { |_, action| action[:error] }).to eq({})
      end

      it "lists platforms added with add_extra_platforms" do
        allow(example_action).to receive(:is_supported?) { |platform| platform == :windows }
        Fastlane::SupportedPlatforms.extra = [:windows]

        expect(Fastlane::ActionsList.generate_json[:actions]["json_example"][:platforms]).to eq([:windows])
      ensure
        Fastlane::SupportedPlatforms.extra = []
      end

      it "lists the platform given with --platform, which the Fastfile may have added" do
        allow(example_action).to receive(:is_supported?) { |platform| platform == :windows }

        expect(Fastlane::ActionsList.generate_json(platform: "windows")[:actions]["json_example"][:platforms]).to eq([:windows])
      end

      it "filters the summary by platform" do
        expect(Fastlane::ActionsList.generate_json(platform: "ios")[:actions]).not_to have_key("json_example")
      end

      it "gives an action's options, with defaults that do not depend on this machine" do
        json = Fastlane::ActionsList.generate_action_json("json_example")

        expect(json).to include(version: 1, name: "json_example", outputs: [{ name: "EXAMPLE_OUTPUT", description: "The output" }], return_type: :string)
        expected = [
          { key: "path", description: "Path", type: "string", optional: false, env_names: ["EXAMPLE_PATH"], default: "./out" },
          { key: "count", description: "Count", type: "integer", optional: true, env_names: [], short_option: "-c" },
          { key: "user", description: "User", type: "string", optional: false, env_names: [], default_is_dynamic: true },
          { key: "token", description: "Token", type: "string", optional: false, env_names: [], sensitive: true },
          { key: "callback", description: "Callback", type: "callback", optional: true, env_names: [] },
          { key: "flag", description: "Flag", optional: false, env_names: [], default: false },
          { key: "old", description: "**DEPRECATED!** Use path - Old", type: "string", optional: true, env_names: [], deprecated: true, deprecation_message: "Use path" },
          { key: "older", description: "**DEPRECATED!** Older", type: "string", optional: true, env_names: [], deprecated: true },
          { key: "legacy", description: "A legacy option" }
        ]
        expect(json[:options]).to eq(expected)
      end

      it "reports an action that raises instead of failing the list" do
        allow(example_action).to receive(:is_supported?).and_raise(LoadError, "cannot load such file -- missing_gem")

        json = Fastlane::ActionsList.generate_json

        expect(json[:actions]["json_example"]).to eq({ error: "LoadError: cannot load such file -- missing_gem" })
        expect(json[:actions]).to have_key("gym")
      end

      it "fails for an unknown action" do
        expect do
          Fastlane::ActionsList.generate_action_json("nonExistingHere")
        end.to raise_error(FastlaneCore::Interface::FastlaneError, /Couldn't find action 'nonExistingHere'/)
      end

      it "writes to STDOUT, which stays clean when $stdout goes to stderr" do
        stdout = $stdout
        $stdout = StringIO.new
        expect(STDOUT).to receive(:puts).with(JSON.generate(Fastlane::ActionsList.generate_action_json("json_example")))
        Fastlane::ActionsList.run(filter: "json_example", json: true)
        expect($stdout.string).to eq("")
      ensure
        $stdout = stdout
      end
    end

    describe "with a class in the Actions namespace that does not extend action" do
      it "trying to show its details presents a helpful error message" do
        require_relative 'fixtures/broken_actions/broken_action.rb'

        expect(UI).to receive(:user_error!).with(/be a subclass/).and_raise("boom")

        expect do
          Fastlane::ActionsList.show_details(filter: 'broken')
        end.to raise_error("boom")
      end
    end
  end
end
