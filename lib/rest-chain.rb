require 'typhoeus'
require 'multi_json'
require 'uri_template'
require 'logger'

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

  attr_accessor :logger, :resource_class

  def included(klass)
    klass.extend(RestChain)
    klass.send :include, Pairing
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
    build(attributes || { })
  end

  #todo clean this shit
  def build(hash, context=nil)
    resource =   hash || { }
    case
    when resource.instance_variable_get(:@__rest_chain_resource)
      resource.instance_variable_set(:@context, context) if context
      resource
    when resource.is_a?(Array)
      build_array(context || self, resource)
    when resource.class == Hash
      resource_class ?  build_custom_resource(context || self,resource) :  build_hash(context || self,resource)
    else
      if resource_class
        build_custom_resource(context || self,resource)
      else
        resource.extend(Resource)
        resource.instance_variable_set(:@context, context || self)
        resource
      end
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



  private

  def build_hash(context, resource={})
    resource.instance_variable_set(:@original, resource.dup)
    resource.instance_variable_set(:@context, context)
    resource.extend(HashAsResource)
    resource.extend(Resource)
    resource
  end

  def build_array(context,resource=[])
    collection = Collection.new(resource)
    collection.instance_variable_set(:@context, context)
    collection
  end


  def build_custom_resource(context,resource)
    unless resource.instance_of?(resource_class)
      resource =  ( resource_class.instance_method(:initialize).parameters.any? ? resource_class.new(resource) : resource_class.new)
    end
    resource.instance_variable_set(:@context, context)
    resource.extend(Resource)
    resource
  end


end

#todo: add suport for unchaining
#todo: add suport for deep loops braking( problem with for custom classes)
