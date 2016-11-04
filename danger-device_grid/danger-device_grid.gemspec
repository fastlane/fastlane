# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'device_grid/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-device_grid'
  spec.version       = DeviceGrid::VERSION
  spec.authors       = ['Felix Krause', 'Boris Bügling']
  spec.email         = ['danger@krausefx.com', 'boris@icculus.org']
  spec.summary       = %q{Danger plugin for the fastlane device grid.}
  spec.homepage      = 'https://github.com/fastlane/fastlane/tree/master/danger-device_grid'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency "fastlane", ">= 1.106.2", "< 2.0.0"

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_junit_formatter', '~> 0.2.3'
  spec.add_development_dependency 'rubocop', '~> 0.44.0'
end
