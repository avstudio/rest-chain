module RestChain
	class LazyResource

		attr_reader :resource

		def initialize(resource)
			@resource = resource
		end

		def method_missing(name, *args, &block)

		end

	end
end
