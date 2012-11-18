describe "Siren" do
  before(:all) do
    RestChain.use :siren
  end

  let(:item) { SIREN_YML['item'].dup }
  let(:customer) { SIREN_YML['customer'].dup }
  let(:actions) { SIREN_YML['actions'].dup }
  let(:links) { SIREN_YML['links'].dup }
  let(:properties) { SIREN_YML['properties'].dup }
  let(:entities) { SIREN_YML['entities'].dup }

  it "class method shout not be ovveriden by siren class attribute" do
    customer.to_rest_chain.class.should == Hash
  end

  it "should load self with self_link" do
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:body => item.to_json)
    resource = { 'href' => "http://api.x.io/orders/42/items" }.to_rest_chain
    resource.self_link.orderNumber.should == 42
  end

  it "should respond to methods" do
    resource = Resource.build(item)
    resource.actions.should be_any
    resource.entities.should be_any
  end

  it "should find  and follow customer" do
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:status => 200, :body => customer.to_json)
    resource = item.to_rest_chain
    resource.customer.customerId.should == 42
  end

  it "should create new item" do
    stub_request(:post, "http://api.x.io/orders/42/items").to_return(:body => item.to_json)
    resource = actions.to_rest_chain
    resource.create(:order_id => 78).orderNumber.should == 42
  end

  it "should create new item by calling the create method through collection" do
    stub_request(:post, "http://api.x.io/orders/42/items").to_return(:body => item.to_json)
    resource = item.to_rest_chain
    resource.create(:order_id => 78).orderNumber.should == 42
  end

  it "should find update action through collection and follow it" do
    updated_item = item.clone
    updated_item["properties"]["status"] = 'active'
    stub_request(:put, "http://api.x.io/orders/42/items").to_return(:body => updated_item.to_json)
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:body => item.to_json)
    resource = item.to_rest_chain
    resource.update(status: 'active').status.should == "active"
  end

  it "should update new item" do
    stub_request(:put, "http://api.x.io/orders/42/items").to_return(:body => item.to_json)
    resource =actions.to_rest_chain
    resource.update(:order_id => 78)
  end

  it "should  load items" do
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:body => properties.to_json)
    resource = item.to_rest_chain
    resource.should be_kind_of(Resource)
    resource.items.orderNumber.should ==42
  end

  it "should  follow users from links" do
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:body => properties.to_json)
    resource = { "links" => [
                   { "rel" => "users", "href" => "http://api.x.io/orders/42/items" },
    { "rel" => "self", "href" => "http://api.x.io/orders/42/items" }] }.to_rest_chain
    resource.should be_kind_of(Resource)
    resource.users.orderNumber.should ==42
  end

  it "should  follow self through the self link in links" do
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:body => properties.to_json)
    resource = { "links" => [
                   { "rel" => "users", "href" => "http://api.x.io/orders/42/items" },
                   { "rel" => "self", "href" => "http://api.x.io/orders/42/items" }
    ] }.to_rest_chain
    resource.self_link
  end


end
