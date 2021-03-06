# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'suggestion_bot/version'

Gem::Specification.new do |spec|
  spec.name          = "suggestion_bot"
  spec.version       = SuggestionBot::VERSION
  spec.authors       = ["crater2150"]
  spec.email         = ["me@crater2150.de"]
  spec.description   = %q{Simple IRC bot for voting on stuff}
  spec.summary       = %q{IRC voting bot}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'cinch'
  spec.add_dependency 'xdg'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
