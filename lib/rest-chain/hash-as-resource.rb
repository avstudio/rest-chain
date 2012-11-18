module RestChain
  module HashAsResource

    def self.extended(resource)
      unless resource.nil?
        class << resource;
          alias_method :delete!, :delete
          alias_method :update!, :update
        end
      end
    end

    def attributes
      self
    end

    #todo make infection module
    def read_attribute(name)
      value = self[name]
      return nil unless value
      self.inflect!(value)
    end

    def write_attribute(name, value)
      self[name] = value
    end


    def update_attributes(attributes={ })
      self.update!(attributes)
    end


    def [](value)
      super(value.to_s) || super(value.to_sym)
    end


    def key?(key)
      (super(key.to_s) || super(key.to_sym))
    end

    alias :attribute? :key?

    def respond_to?(name)
      super(name.to_sym) || key?(name)
    end

    def lazy?
      key?('href')
    end

    def chain_path__(*args)
      res = super(*args)
      p "context from"
      p context
      p "res context before"
      res.respond_to?(:to_rest_chain) ? res.to_rest_chain(context) : res
       "res context after"
      res
    end

    def reload
      clear
      update_attributes(original)
      context.api.non_lookup_rules.each { |rule| rule.apply_on(self) }
      self
    end

  end
end
