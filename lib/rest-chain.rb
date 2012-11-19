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
require 'rest-chain/inflection'
require 'rest-chain/collection'
require 'rest-chain/adapters/abstract-adapter'
require 'rest-chain/adapters/typhoeus-adapter'
#require 'rest-chain/lazy-resource'
require 'rest-chain/resource'
require 'rest-chain/hash-as-resource'
require 'rest-chain/api'
require 'rest-chain/definitions/siren'



module RestChain
  extend self

  attr_reader :default_rest_chain_options
  @default_rest_chain_options = {}



  def self.included(klass)
    klass.extend(RestChain)
    class << klass; attr_accessor :default_rest_chain_options end
    klass.instance_variable_set(:@default_rest_chain_options, {})
  end


  def logger
    default_rest_chain_options[:logger] ||= Logger.new(STDOUT)
  end


  def api
    default_rest_chain_options[:selected_definition] ||= API.definition_for(:siren)
  end

  def use(name)
    default_rest_chain_options[:selected_definition] = API.definition_for(name)
  end

  def adapter(adap = nil)
    return (default_rest_chain_options[:adapter] ||=  Adapters::TyphoeusAdapter.new) unless adap
    default_rest_chain_options[:adapter] = adap
  end

  def adapter=(klass)
    default_rest_chain_options[:adapter] = klass.new
  end

  def headers
    default_rest_chain_options[:headers] ||= { :headers => { :Accept => "application/json", :"Content-Type" => "application/json" } }
  end

  def add_to_headers(hash={ })
    headers[:headers].merge!(hash)
  end

  def entry_point(url=nil)
    return default_rest_chain_options[:entry_point] unless url
    default_rest_chain_options[:entry_point] = url
  end

  def resource_class(klass=nil)
    return default_rest_chain_options[:resource_class] unless klass
    default_rest_chain_options[:resource_class] = klass
  end


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
        resource.instance_variable_set(:@context, context || self)
        resource.extend(Resource)
        resource
      end
    end
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
