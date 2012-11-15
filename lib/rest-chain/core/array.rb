class Array
  #todo clean this
  def chain_path(*args)
    dotted_path, match_value, options = args
    if match_value.is_a?(Hash)
      match_value = nil
      options     = { }
    end
    options ||= { }
    context = self.respond_to?(:context) ? self.context : RestChain
    path    = dotted_path.split('.', 2)
    key     = path.shift
    parent  = options[:parent]
    collect = options[:collect]
    output  =[]
    each do |el|
      next unless  el.key?(key)
      if  path.any?
        new_el = (el[key].chain_path(path.join('.'), match_value, options)
                  next unless new_el
                  output << new_el.to_rest_chain(context))
      else
        next if match_value && match_value != el[key]
        to_out = (parent ? el : el[key])
        output << (to_out.respond_to?(:to_rest_chain) ? to_out.to_rest_chain(context) : to_out)
      end
      !output.nil? && !collect ? break : next
    end
    collect ? output : output.first
  end

  def to_rest_chain(context=nil)
    RestChain.build(self, context)
  end

end
