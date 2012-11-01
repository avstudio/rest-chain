module RestChain
  module API
    module Lookup
      extend self

      #todo clean this
      def method_missing(name, *args, &block)

        if !respond_to?(:write_attribute) && !respond_to?(:read_attribute)
          raise("Oops. RestChain needs something from you. If you want to use custom class, you have to define some methods. Read README for more information ")
        end

        if name.to_s =~ /(.*)=$/
          write_attribute(name, *args)
          return read_attribute(name)
        end

        value = self.read_attribute(name)
        return value if value
        return nil if context.api.safe_attributes.include?(name.to_sym)

        filtered = nil
        context.api.lookup_rules.each do |rule|
          filtered = rule.apply_on(self, name.to_s, *args, &block)
          filtered.nil? ? next : break
        end
        return filtered.to_rest_chain(context) if filtered

        if pair = context.pairs[name.to_sym]
          return pair
        end


        raise("Oops. The chain is broken :(. There is no :#{name} to follow! ")
      end

    end
  end
end
