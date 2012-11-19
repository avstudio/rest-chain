describe "RestChain" do
  let!(:properties) { SIREN_YML['properties'] }

  describe "Inflection" do

    it "should inflect new object by reading it" do
      host = { }.to_rest_chain
      host.should respond_to(:inflect!)
      host.merge!({ :a => { } })
      host.read_attribute(:a).should respond_to(:inflect!)
      host.read_attribute(:a).should be_kind_of(RestChain::Resource)
    end

    it "should change context of the inflected object" do
      host = { }.to_rest_chain(Client)
      host.context.should be(Client)
      for_infection = { :a => { } }.to_rest_chain
      for_infection.context.should == RestChain
      host.inflect!(for_infection)
      for_infection.context.should == Client
    end

  end

  it "should set original to the infected object" do
    original = properties.clone
    resource = properties.clone.to_rest_chain
    resource.orderNumber.should ==42
    resource.original.should == original
  end

end
