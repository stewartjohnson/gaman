# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gaman/version'

Gem::Specification.new do |spec|
  spec.name          = "gaman"
  spec.version       = Gaman::VERSION
  spec.authors       = ["Stewart M. Johnson"]
  spec.email         = ["stewart@bolidian.com"]
  spec.summary       = %q{Provides an API and CLI for the FIBS backgammon server.}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "curses"
  spec.add_runtime_dependency "i18n"
end
