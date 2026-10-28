require "yaml"
require_relative "../internal/plugin_template_rubocop_config"

describe Fastlane::Internal::PluginTemplateRubocopConfig do
  let(:root) { File.expand_path("..", __dir__) }
  let(:config) { YAML.safe_load_file(File.join(root, ".rubocop.yml"), aliases: true) }
  let(:template_config) { described_class.from(config) }
  # Read from the source, not from the registry the implementation uses.
  let(:internal_cops_by_file) do
    Dir[File.join(root, "internal/rubocop/*.rb")].to_h { |file| [file, File.read(file).scan(/^\s*class (\w+) < (?:RuboCop::Cop::)?Base$/).flatten] }
  end
  let(:internal_cop_names) { internal_cops_by_file.values.flatten }
  let(:internal_cop_keys) { config.keys.select { |key| internal_cop_names.include?(key.split("/").last) } }

  it "finds a cop in every file of internal/rubocop" do
    expect(internal_cops_by_file.select { |_, cops| cops.empty? }.keys).to be_empty
  end

  it "drops the configuration of the cops in internal/rubocop, which plugins do not load" do
    expect(internal_cop_keys).not_to be_empty
    expect(template_config.keys & internal_cop_keys).to be_empty
  end

  it "requires none of the files in internal/" do
    expect(config["require"]).to include(start_with("./internal/"))
    expect(template_config["require"]).not_to include(start_with("./internal/"))
    expect(template_config["require"]).to include("rubocop/require_tools")
  end

  it "keeps everything else but inherit_from" do
    expect(template_config.except("require")).to eq(config.except("require", "inherit_from", *internal_cop_keys))
  end
end
