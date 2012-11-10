require 'typhoeus'
require 'multi_json'
require 'uri_template'
require 'logger'
require 'forwardable'

$:.unshift(File.expand_path(File.dirname(__FILE__))) unless  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rest-chain/core/array'
require 'rest-chain/core/hash'
require 'rest-chain/link'
require 'rest-chain/error'
require 'rest-chain/response'
require 'rest-chain/pairing'
require 'rest-chain/collection'
require 'rest-chain/adapters/abstract-adapter'
require 'rest-chain/adapters/typhoeus-adapter'
require 'rest-chain/lazy-resource'
require 'rest-chain/resource'
require 'rest-chain/hash-as-resource'
require 'rest-chain/api'
require 'rest-chain/definitions/siren'


module RestChain
	extend self
	include Pairing

	attr_accessor :logger

	def included(klass)
		klass.extend(RestChain)
	end

	def logger
		@logger ||= Logger.new(STDOUT)
	end

	def configure(&block)
		instance_eval(&block)
	end


	def api
		@selected_definition ||= API.definition_for(:siren)
	end


	def use(name)
		@selected_definition = API.definition_for(name)
	end


	def resource_class(name=nil)
		@resource_class = name if name
		@resource_class
	end


	def adapter
		@adapter ||= Adapters::TyphoeusAdapter.new
	end

	def adapter=(klass)
		@adapter = klass.new
	end

	def headers
		@headers ||= { :headers => { :Accept => "application/json", :"Content-Type" => "application/json" } }
	end

	def add_to_headers(hash={ })
		headers[:headers].merge!(hash)
	end


	def new(attributes={ }, &block)
		resource_class ? build(resource_class.new(attributes, &block)) : build(attributes || { })
	end

	#todo move inside some module or something
	def build(hash, context=nil)
		resource = (hash || { })
		begin
			case
				when resource.kind_of?(Resource)
					resource.instance_variable_set(:@context, context) if context
					resource
				when resource.kind_of?(Collection)
					resource.instance_variable_set(:@context, context) if context
					resource
				when resource.is_a?(Array)
					collection = Collection.new(resource)
					collection.instance_variable_set(:@context, context || self)
					collection
				else
					resource.instance_variable_set(:@original, resource.dup)
					resource.instance_variable_set(:@context, context || self)
					resource.extend(Resource)
					resource.extend(HashAsResource) if resource.is_a?(Hash)
					resource.extend api.lookup
					api.non_lookup_rules.each { |rule| rule.apply_on(resource) }
					resource
			end
		rescue
			raise("Oops. This is not the valid RestChain object :(. Got:  #{resource} ")
		end
	end

	def entry_point(url=nil)
		@entry_point = url if url
		@entry_point
	end


	def link_to(options= { }, &block)
		Link.new(self, options, &block)
	end



	def follow(name_or_url= nil, params={ }, &block)
		response = case
			           when name_or_url.nil? || name_or_url == :self
				           link_to('href' => entry_point).follow(params, &block)
			           else
				           link_to('href' => name_or_url).follow(params, &block)
		           end
		response.to_rest_chain(self) if response
		response
	end
	alias :at :follow


	def connect(params={ }, &block)
		follow(:self, params, &block)
	end

end







