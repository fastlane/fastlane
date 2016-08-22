# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xcode/install/version'

Gem::Specification.new do |spec|
  spec.name          = 'xcode-install'
  spec.version       = XcodeInstall::VERSION
  spec.authors       = ['Boris Bügling']
  spec.email         = ['boris@icculus.org']
  spec.summary       = 'Xcode installation manager.'
  spec.description   = 'Download, install and upgrade Xcodes with ease.'
  spec.homepage      = 'https://github.com/neonichu/xcode-install'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.0.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'claide', '>= 0.9.1', '< 1.1.0'
  spec.add_dependency 'spaceship', '>= 0.25.1', '< 1.0.0'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
