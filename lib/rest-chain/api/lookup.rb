module RestChain
  module API
    module Lookup
      def self.included(klass)
        klass.singleton_class.class_eval do
          def extended(resource)
            extension = Module.new do
              meta = (class  << resource; self; end)
              resource.attributes.each_pair do |k,v|
                _k = k
                meta.send( :define_method, _k  ){read_attribute( _k)} unless respond_to?(k.to_sym)  ||  resource.respond_to?(k.to_sym)#fix for class
              end
              resource.suggest.each do |name|
                define_method name do |*args, &block|
                  filtered = nil
                  context.api.lookup_rules.each do |rule|
                    filtered = rule.apply_on(self, name.to_s, *args, &block)
                    filtered.nil? ? next : break
                  end
                  inflect!(filtered) if filtered
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
