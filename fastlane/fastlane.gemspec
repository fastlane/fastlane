# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/version'

# Copy over the latest .rubocop.yml style guide
rubocop_config = File.expand_path('../../.rubocop.yml', __FILE__)
`cp #{rubocop_config} #{lib}/fastlane/plugins/template/.rubocop.yml`

Gem::Specification.new do |spec|
  spec.name          = "fastlane"
  spec.version       = "2.0.0"
  spec.authors       = ["Felix Krause", "Michael Furtak", "Andrea Falcone", "Sam Phillips", "David Ohayon", "Sam Robbins", "Mark Pirri", "Hemal Shah"]
  spec.email         = ["fastlane@krausefx.com"]
  spec.summary       = Fastlane::DESCRIPTION
  spec.description   = Fastlane::DESCRIPTION
  spec.homepage      = "https://fastlane.tools"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0.0'

  spec.files = Dir.glob("lib/**/*", File::FNM_DOTMATCH) + %w(bin/fastlane bin/🚀 README.md LICENSE) - Dir.glob("lib/fastlane/actions/device_grid/assets/*")

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

end
