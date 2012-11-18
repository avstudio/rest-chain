module RestChain
  module Resource
    attr_reader :context, :original

    def self.extended(resource)
      resource.instance_variable_set(:@__rest_chain_resource,true)

      meta =  resource.singleton_class
      for_implementation =  [:read_attribute, :attribute? ,:write_attribute ,:update_attributes ,:reload ,:chain_path ,:lazy?]
      for_implementation.each do |meth|
        raise NotImplementedError, "If you want to use custom class as RestChain resource, please implement necessary methods. Read README for more info. Missing method :#{meth}" unless resource.respond_to?(meth)
      end
      resource.extend Inflection
      resource.context.api.non_lookup_rules.each { |rule| rule.apply_on(resource) }
      resource.extend resource.context.api.lookup
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


  end
end
