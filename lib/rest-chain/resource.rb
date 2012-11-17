module RestChain
  module Resource
    attr_reader :context, :original

    def self.extended(resource)
      resource.instance_variable_set(:@__rest_chain_resource,true)
      resource.context.api.non_lookup_rules.each { |rule| rule.apply_on(resource) }
      resource.extend resource.context.api.lookup
      %w{read_attribute attribute? write_attribute update_attributes reload chain_path lazy?}.each do |meth|
        singleton_class.send :define_method  , meth do |*|
          raise NotImplementedError, "If you want to use custom class as RestChain resource, please implement necessary methods. Read README for more info"
        end unless singleton_class.method_defined?(meth)
      end
    end

    def loaded?
      !lazy?
    end

    def api
      context.api
    end

    def lazy
      raise NotImplementedError, "Currently not supported"
    end

    def link_to(options= { })
      context.link_to(options)
    end


    def suggest
      context.api.suggestions_for(self)
    end
    alias :suggestions :suggest


    def follow(name_or_url= nil, params={ }, &block)
      case
      when name_or_url.nil? || name_or_url ==:self
        self_link(self)
      when name_or_url.is_a?(String)
        context.link_to({ 'href' => name_or_url }.merge(params), &block).follow
      when name_or_url.is_a?(Hash) || name_or_url.kind_of?(Resource)
        context.link_to(name_or_url.merge(params), &block).follow
      else
        raise(BrokenChainError,"Oops. The chain is broken :(. Invalid URL to follow! Got: #{name_or_url} ")
      end
    end

    #todo move to the inflection module
    ###########################################################

    def inflect!(object)
      return object unless object.respond_to?(:to_rest_chain)
      inflected = object.to_rest_chain
      inflected.instance_variable_set(:@context, self.context)
      inflected
    end
    ###########################################################

  end
end
