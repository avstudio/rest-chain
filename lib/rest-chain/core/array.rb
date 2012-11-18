class Array

  def chain_path(*args)
    dotted_path, match_value, options = args
    if match_value.is_a?(Hash)
      options     = match_value
      match_value = nil
    end
    options ||= { }
    parts   = dotted_path.split('.', 2)
    context = self.respond_to?(:context) ? self.context : RestChain
    key     = parts[0]
    parent  = options[:parent] || false
    collect = options[:collect] || false
    output  = []
    each do |el|
      next unless  el.key?(key)
      if  parts[1]
        new_el = el[key].chain_path(parts[1], match_value, options)
        next unless new_el
        output << (new_el.respond_to?(:to_rest_chain) ? new_el.to_rest_chain(context) : new_el)
      else
        next if match_value && match_value != el[key]
        #output << (parent ? el : el[key])
        to_out = (parent ? el : el[key])
        output <<  (to_out.respond_to?(:to_rest_chain) ? to_out.to_rest_chain(context) : to_out)
      end
      (output.empty? || collect) ? next : break
    end
    ( collect ? output : output.first)
  end

  def to_rest_chain(context=nil)
    RestChain.build(self, context)
  end

end
