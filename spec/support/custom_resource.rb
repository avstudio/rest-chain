class CustomResource

  def initialize(attributes={})
    meta = class << self; self end
    attributes.each do |key, value|
      meta.send( :define_method , key){value}
    end
  end



  def read_attribute(*)
  end

  def attribute?(*)
  end

  def write_attribute(*)
  end

  def update_attributes(*)
  end

  def lazy
  end

  def reload
  end


  def lazy?
  end


end
