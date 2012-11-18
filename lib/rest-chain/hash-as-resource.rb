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
      inflect! self[name]
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

    def chain_path(*args)
      inflect! super(*args)
    end

    def reload
      clear
      update_attributes(original)
      context.api.non_lookup_rules.each { |rule| rule.apply_on(self) }
      self
    end

  end
end
