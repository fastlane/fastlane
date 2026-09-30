require 'yaml'
require 'open3'

# Fastlane::MINIMUM_RUBY is the minimum Ruby; this fails a change that leaves a copy of it, CI or the executable behind.
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

  it "tests the minimum Ruby itself" do
    pinned = Dir[File.join(root, ".github", "workflows", "*.yml")].flat_map { |workflow| pinned_rubies(YAML.load_file(workflow)) }

    expect(pinned.map { |version| Gem::Version.new(version) }).to include(minimum_version(requirement))
  end

  it "states Fastlane::MINIMUM_RUBY in fastlane.gemspec" do
    expect(requirement).to eq(Gem::Requirement.new(">= #{Fastlane::MINIMUM_RUBY}"))
  end

  it "has bin/fastlane refuse a Ruby below Fastlane::MINIMUM_RUBY" do
    raise_minimum = 'require "fastlane/version"; Fastlane.send(:remove_const, :MINIMUM_RUBY); Fastlane::MINIMUM_RUBY = "99.0.0"; load ARGV.first'
    output, status = Open3.capture2e(RbConfig.ruby, "-I", File.join(root, "fastlane", "lib"), "-e", raise_minimum, File.join(root, "bin", "fastlane"))

    expect([status.exitstatus, output.strip]).to eq([1, "fastlane requires Ruby 99.0.0 or higher"])
  end

  it "targets Fastlane::MINIMUM_RUBY in .rubocop.yml" do
    target = YAML.load_file(File.join(root, ".rubocop.yml")).dig("AllCops", "TargetRubyVersion")

    expect(Gem::Version.new(target.to_s)).to eq(minimum_version(requirement))
  end

  describe "the plugin template" do
    template = File.join(root, "fastlane", "lib", "fastlane", "plugins", "template")
    let(:workflow) { YAML.load_file(File.join(template, ".github", "workflows", "test.yml")) }

    it "requires fastlane's minimum Ruby" do
      expect(File.read(File.join(template, "%gem_name%.gemspec.erb"))).to include("spec.required_ruby_version = '>= <%= Fastlane::MINIMUM_RUBY %>'")
    end

    it "only tests Rubies fastlane supports" do
      too_old = pinned_rubies(workflow).reject { |version| requirement.satisfied_by?(Gem::Version.new(version)) }

      expect(too_old).to be_empty, "the plugin template's test.yml pins #{too_old.uniq.join(', ')}, below #{requirement}"
    end

    it "tests the minimum Ruby itself" do
      expect(pinned_rubies(workflow).map { |version| Gem::Version.new(version) }).to include(minimum_version(requirement))
    end
  end
end
