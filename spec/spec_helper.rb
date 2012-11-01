require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
	require 'rspec'
	require 'rack/test'
	require "rest-chain"
	require 'webmock/rspec'
	require 'json'
	require "awesome_print"
  $:<< './lib'
  require 'rest-chain'
	SIREN_YML = YAML.load(File.read(File.dirname(__FILE__) +"/support/siren.yml"))

	include RestChain
	RestChain.entry_point "http://localhost:9292"
	RestChain.use :siren

	RSpec.configure do |config|
		config.include Rack::Test::Methods
	end

end


