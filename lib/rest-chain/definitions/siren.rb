RestChain::API::Definition.describe :siren do


  define :on_load do |resource|
    resource.write_attribute('self_class',resource.read_attribute("class")) if resource.attribute?('class')  #to make Ruby to work
    resource.update_attributes(resource.read_attribute('properties'))  if resource.attribute?('properties')
    resource
  end



  #todo recognize  and group collection
  define :entities, lookup: true, suggest: :rel do |resource, method_name|
    next unless resource.attribute?('entities')
    #group_by_proc = Proc.new { |el| el.values.first }
    #child         = resource.chain_path("entities.rel", method_name).group_by(&group_by_proc).first
    child = resource.chain_path("entities.rel", method_name, parent: true)
    if child
      if (href = child.href)
        resource.write_attribute(method_name, end_point("href" => href).follow)
      else
        resource.write_attribute(method_name, child)
      end
      next resource.read_attribute(method_name)
    end
    if (link = resource.chain_path("entities.links.rel", method_name, parent: true))
      resource.write_attribute(method_name, end_point(link).follow)
      next resource.read_attribute(method_name)
    end
    next
  end



  define :actions, lookup: true, suggest: :name do |resource, method_name, *args, &block|
    next unless resource.attribute?('actions')
    action = resource.chain_path("actions.name", method_name, parent: true)
    next unless action
    next unless action.attribute?('href')
    resource.write_attribute(method_name, end_point(action).follow(*args) || { })
    resource.read_attribute(method_name)
  end



  define :links, lookup: true, suggest: :rel do |resource, method_name, *args, &block|
    next unless resource.attribute?('links')
    link = resource.chain_path('links.rel', method_name, parent: true)
    next unless link
    proc = Proc.new { |response| resource.write_attribute(method_name, response) }
    end_point(link).follow(*args, &proc)
    resource.instance_eval(&block) if block_given?
    resource.read_attribute(method_name)
  end



  #static methods
  define_lookup_method :self_link do |resource|
    link = resource.read_attribute(:href)
    link ||= resource.chain_path('links.rel', 'self', parent: true)
    return nil unless link
    resource.follow link
  end

end
