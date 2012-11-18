module RestChain
  module Inflection

    def self.extended(resource)
      meta =  resource.singleton_class
      read_attr_meth = resource.method(:read_attribute) rescue nil
      meta.send :define_method, :read_attribute do |name|
        inflect! read_attr_meth.call(name)
      end if read_attr_meth
    end


    def inflect!(object)
      return object unless object.respond_to?(:to_rest_chain)
      inflected = object.to_rest_chain(self.context)
      inflected.instance_variable_set(:@context, self.context)
      inflected
    end

  end
end
