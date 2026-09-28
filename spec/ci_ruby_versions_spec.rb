require 'yaml'

# The minimum Ruby is written in several files; this fails the change that raises it until they all follow.
describe "Ruby versions" do
  root = File.expand_path("..", __dir__)

  # Every Ruby a workflow pins, from ruby-version: and from matrix `ruby` entries. Expressions are
  # skipped: ${{ matrix.ruby }} resolves to values listed elsewhere in the same file.
  def pinned_rubies(node)
    case node
    when Hash
      node.flat_map do |key, value|
        values = %w[ruby ruby-version].include?(key) ? Array(value).reject { |v| v.to_s.include?("${{") }.map(&:to_s) : []
        values + pinned_rubies(value)
      end
    when Array
      node.flat_map { |value| pinned_rubies(value) }
    else
      []
    end
  end

  def minimum_version(requirement)
    requirement.requirements.find { |op, _| op == ">=" }.last
  end

  let(:requirement) { Gem::Specification.load(File.join(root, "fastlane.gemspec")).required_ruby_version }

  Dir[File.join(root, ".github", "workflows", "*.yml")].each do |workflow|
    it "#{File.basename(workflow)} only runs Rubies that fastlane supports" do
      too_old = pinned_rubies(YAML.load_file(workflow)).reject { |version| requirement.satisfied_by?(Gem::Version.new(version)) }

      expect(too_old).to be_empty, "#{File.basename(workflow)} pins #{too_old.uniq.join(', ')}, below fastlane.gemspec's #{requirement}"
    end
  end

  it "targets the minimum Ruby in .rubocop.yml" do
    target = YAML.load_file(File.join(root, ".rubocop.yml")).dig("AllCops", "TargetRubyVersion")

    expect(Gem::Version.new(target.to_s)).to eq(minimum_version(requirement))
  end

  describe "the plugin template" do
    template = File.join(root, "fastlane", "lib", "fastlane", "plugins", "template")

    let(:template_requirement) do
      Gem::Requirement.new(File.read(File.join(template, "%gem_name%.gemspec.erb"))[/required_ruby_version = '([^']+)'/, 1])
    end

    it "requires the same minimum Ruby as fastlane" do
      expect(template_requirement).to eq(requirement)
    end

    it "only tests Rubies its gemspec supports" do
      workflow = File.join(template, ".github", "workflows", "test.yml")
      too_old = pinned_rubies(YAML.load_file(workflow)).reject { |version| template_requirement.satisfied_by?(Gem::Version.new(version)) }

      expect(too_old).to be_empty, "the plugin template's test.yml pins #{too_old.uniq.join(', ')}, below its gemspec's #{template_requirement}"
    end
  end
end
