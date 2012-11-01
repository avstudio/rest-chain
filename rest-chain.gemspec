$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rest-chain/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
	s.name        = "rest-chain"
	s.version     = RestChain::VERSION
	s.authors     = ["Aleksandar Vucic"]
	s.email       = ["contact@vucicaleksandar.com"]
	s.homepage    = "https://github.com/avstudio/rest-chain.git"
	s.summary     = "Hypermedia client."
	s.description = "Hypermedia aware resource based library in ruby"

  s.rubyforge_project = "rest-chain"

	s.files         = `git ls-files`.split("\n")
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.require_paths = ["lib"]

	s.add_dependency "multi_json"
	s.add_dependency "typhoeus"
	s.add_dependency "logger"
	s.add_dependency 'uri_template'
	s.add_development_dependency "webmock"
	s.add_development_dependency "spork"
	s.add_development_dependency "rspec"
	s.add_development_dependency "rack-test"
	s.add_development_dependency "awesome_print"
	s.add_development_dependency "oj"
end
