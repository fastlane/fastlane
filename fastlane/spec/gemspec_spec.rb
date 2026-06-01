describe "fastlane.gemspec" do
  let(:specification) { Gem::Specification.load(File.expand_path("../../fastlane.gemspec", __dir__)) }
  let(:jwt_requirement) { specification.dependencies.find { |dependency| dependency.name == "jwt" }.requirement }

  it "requires a jwt version that rejects empty HMAC keys" do
    expect(jwt_requirement).not_to be_satisfied_by(Gem::Version.new("2.10.2"))
    expect(jwt_requirement).to be_satisfied_by(Gem::Version.new("2.10.3"))
    expect(jwt_requirement).not_to be_satisfied_by(Gem::Version.new("3.1.2"))
    expect(jwt_requirement).to be_satisfied_by(Gem::Version.new("3.2.0"))
  end
end
