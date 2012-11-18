class CustomResource < Hash
  def initialize(attributes={})
    merge!(attributes) rescue nil
    extend RestChain::HashAsResource
  end

  def action( name)
    _actions = read_attribute(:actions)
    return nil unless _actions
    _actions.chain_path('name',name.to_s,parent:true)
  end
end
