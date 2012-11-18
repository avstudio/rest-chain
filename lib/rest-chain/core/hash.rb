class Hash
  #todo clean this
  def chain_path(*args)
    dotted_path, match_value, options = args
    if match_value.is_a?(Hash)
      options     = match_value
      match_value = nil
    end
    options ||= { }
    context = self.respond_to?(:context) ? self.context : nil
    parent  = options[:parent]
    parts   = dotted_path.split('.', 2)
    match   = self[parts[0]]
    match =  match.to_rest_chain(context) if match && match.respond_to?(:to_rest_chain)
    return nil if parts[0].nil?
    return parent ? self : match if parts[1].nil? || match.nil?
    match.chain_path(parts[1], match_value, options)
  end
 
  def to_rest_chain(context=nil)
    RestChain.build(self, context)
  end

end
