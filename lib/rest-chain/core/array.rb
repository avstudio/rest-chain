class Array

  def chain_path(*args)
    dotted_path, match_value, options = args
    if match_value.is_a?(Hash)
      options     = match_value
      match_value = nil
    end
    options ||= { }
    parts   = dotted_path.split('.', 2)
    key     = parts[0]
    parent , collect = options[:parent] || false, options[:collect] || false
    output  = []
    each do |el|
      next unless  el.key?(key)
      if  parts[1]
        new_el = el[key].chain_path(parts[1], match_value, options)
        next unless new_el
        output << new_el
      else
        next if match_value && match_value != el[key]
        output <<  (parent ? el : el[key])
      end
      (output.empty? || collect) ? next : break
    end
    output.flatten!
    ( collect ? output : output.first)
  end

  def to_rest_chain(new_context=nil)
    new_context ||= self.context if respond_to?(:context)
    new_context ? new_context.build(self, new_context) : RestChain.build(self, new_context)
  end

end
