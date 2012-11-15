describe "Resource" do


  it "should respond to dynamic method" do
    { :id => "5" }.to_rest_chain.should respond_to(:id)
    { :id => "5" }.should_not respond_to(:id)
  end


  it "should get attribute value" do
    resource = { :title => "title" }.to_rest_chain
    resource.title.should == "title"
  end


  it "should reload self" do
    resource = { 'properties' => { 'title' => 'old_title' } }.to_rest_chain
    resource.title.should == 'old_title'
    resource.write_attribute('title', 'new_title')
    resource.title.should == 'new_title'
    resource.reload.title.should == 'old_title'
  end


  it "should pair client" do
    google = { 'href' => 'http://www.google.com' }.to_rest_chain
    yahoo  = { 'href' => 'http://www.yahoo.com' }.to_rest_chain
    google.pair(:yahoo, yahoo)
    google.context.pairs.should include(:yahoo)
  end

  it "should pair and respond to the paired client method" do
    google = { 'href' => 'http://www.google.com' }.to_rest_chain
    yahoo  = { 'href' => 'http://www.yahoo.com', 'properties' => { 'name' => "yahoo" } }.to_rest_chain
    google.pair(:yahoo, yahoo)
    google.yahoo.name.should == "yahoo"
  end

  it "should pair and respond to the paired client method trought different context" do
    google = Client.build('href' => 'http://www.google.com') 
    yahoo = Client.build('href' => 'http://www.yahoo.com', 'properties' => { 'name' => "yahoo" }) 
    google.pair(:yahoo, yahoo)
    RestChain.pairs.should be_empty
    Client.pairs.should_not be_empty
    google.yahoo.name.should == "yahoo"
  end



  it "should build rest chain object from different resource class" do
     RestChain.resource_class =  CustomResource
     CustomResource.new( :title=>"something").title.should == "something"
     resource = RestChain.build(:title=>"something")
     resource.title.should =="something"
     resource.should be_kind_of(CustomResource)
     resource.should respond_to(:read_attribute)
  end


end
