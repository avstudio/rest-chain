module RestChain
  module API
    module Lookup
      extend self

      #todo clean this
      def method_missing(name, *args, &block)
        super if name == :to_ary

        if name.to_s =~ /(.*)=$/
          write_attribute(name, *args)
          return read_attribute(name)
        end

        value = self.read_attribute(name)
        return value if value

        filtered = nil
        context.api.lookup_rules.each do |rule|
          filtered = rule.apply_on(self, name.to_s, *args, &block)
          filtered.nil? ? next : break
        end
        return filtered.to_rest_chain(context) if filtered
        if context && context.respond_to?(:pairs) && client_pair = context.pairs[name.to_sym]
          return client_pair
        end


        if name.to_s =~ /(.*)!$/
          raise(BrokenChainError,"Oops. The chain is broken :(. There is no :#{name} to follow! ")
        end
        nil
      end

    end
  end
end
