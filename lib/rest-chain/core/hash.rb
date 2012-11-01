class Hash
	#todo clean this
	def chain_path(*args)
		dotted_path, match_value, options = args
		if match_value.is_a?(Hash)
			match_value = nil
			options     = { }
		end
		options ||= { }
		context = self.respond_to?(:context) ? self.context : nil
		parent  = options[:parent]
		parts   = dotted_path.split('.', 2)
		match   = self[parts[0]]
		return nil if parts[0].nil?
		return parent ? self.to_rest_chain : (match.to_rest_chain(context) rescue nil) if parts[1].nil? || match.nil?
		match.chain_path(parts[1], match_value, options)
	end

	def to_rest_chain(context=nil)
		return self if self.kind_of?(RestChain::Resource)
		RestChain.build(self, context)
	end

end
