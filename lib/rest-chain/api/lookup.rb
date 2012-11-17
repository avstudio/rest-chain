module RestChain
  module API
    module Lookup
      #Of course, it's not nice, but is safer then method_mising and deep stack levels.
      # This is just decorator for our resource.
      #
      #For the instance of the hash,
      # each key will be defined as method to the anonimeous module....
      def self.included(klass)
        klass.singleton_class.class_eval do |variable|
          def extended(resource)
            extension = Module.new do
              resource.each_pair do |k,v|
                define_method( k ) {read_attribute( k)}
              end
              resource.suggest.each do |name|
                define_method name do | *args, &block|
                  filtered = nil
                  context.api.lookup_rules.each do |rule|
                    filtered = rule.apply_on(self, name.to_s, *args, &block)
                    filtered.nil? ? next : break
                  end
                  filtered.to_rest_chain(context) if filtered
                end
              end
            end
            resource.extend(extension)
          end
        end
      end
    end
  end
end
