require 'rubygems'
require 'spork'
require 'pry'
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
  Dir[File.join(File.dirname(__FILE__) + '/support/*.rb')].each { |f| require f }

  RestChain.entry_point "http://localhost:9292"
  RestChain.use :siren

  RSpec.configure do |config|
    config.include Rack::Test::Methods
    config.before do
      rc_conf =  RestChain.instance_variable_get :@default_rest_chain_options
      cl_conf =  Client.instance_variable_get :@default_rest_chain_options
      rc_conf[:resource_class] =cl_conf[:resource_class] = nil
    end
  end
end
