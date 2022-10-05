# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby-prolog/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-prolog"
  spec.version       = RubyProlog::VERSION
  spec.authors       = ["Preston Lee"]
  spec.email         = ["preston.lee@prestonlee.com"]
  spec.description   = "A pure Ruby implementation of a useful subset of Prolog."
  spec.summary       = "A Prolog-ish Ruby DSL."
  spec.homepage      = "http://github.com/preston/ruby-prolog"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", '~> 2.3.7'
  spec.add_development_dependency "rake", "~> 13"
  spec.add_development_dependency "minitest", "~> 5.16.3"
  spec.add_development_dependency "minitest-focus", "~> 1.3.1"
end
