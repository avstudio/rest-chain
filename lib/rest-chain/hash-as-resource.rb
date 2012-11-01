module RestChain
	module HashAsResource

		def self.extended(resource)
			unless resource.nil?
				meta = class << resource;
					self
				end
				meta.send :alias_method, :delete!, :delete
				meta.send :alias_method, :update!, :update
				meta.send :undef_method, :delete
				meta.send :undef_method, :update
			end
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

		def reload
			clear
			update_attributes(original)
			context.api.non_lookup_rules.each { |rule| rule.apply_on(self) }
			self
		end

	end
end
