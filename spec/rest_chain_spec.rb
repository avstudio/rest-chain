describe "RestChain" do
  let!(:properties) { SIREN_YML['properties'] }
  before do
    RestChain.unpair_all
  end

  after do
    RestChain.unpair_all
  end
  describe "Inflection" do

    it "should inflect new object by reading it" do
      host = { }.to_rest_chain
      host.should respond_to(:inflect!)
      host.merge!({ :a => { } })
      host.read_attribute(:a).should respond_to(:inflect!)
      host.read_attribute(:a).should be_kind_of(Resource)
    end

    it "should change context of the inflected object" do
      host = { }.to_rest_chain(Class)
      host.context.should be(Class)
      for_infection = { :a => { } }.to_rest_chain
      for_infection.context.should be(RestChain)
      host.inflect!(for_infection)
      for_infection.context.should be(Class)
    end

  end

  it "should set original to the infected object" do
    original = properties.clone
    resource = properties.clone.to_rest_chain
    resource.orderNumber.should ==42
    resource.original.should == original
  end


  it "should not pair object which is not the RestChain resource" do
    google = { 'href' => 'http://www.google.com' }
    expect { RestChain.pair(:google, google) }.to raise_error
  end

  it "should pair client" do
    google = { 'href' => 'http://www.google.com' }.to_rest_chain
    RestChain.pair(:google, google)
    RestChain.pairs.should include(:google)
  end

  it "should unpair client" do
    RestChain.unpair(:google)
    RestChain.pairs.should_not include(:google)
  end

end
