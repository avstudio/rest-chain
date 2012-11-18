describe "CustomResource" do
  let(:item) { SIREN_YML['item'].dup }
  let(:customer) { SIREN_YML['customer'].dup }
  let(:actions) { SIREN_YML['actions'].dup }
  let(:example_hash){{
                       "properties" => {
                         "totalCount" => 3
                       },
                       "links" => [
                         {
                           "rel" => "users",
                           "href" => "/users/"
                         },
                         {
                           "rel" => "authenticate",
                           "href" => "/users/authenticate"
                         }
                       ],
  }}

  it "should become RestChain object" do
    CustomResource.new.to_rest_chain.context.should == RestChain
  end

  it "should responde to title" do
    resource = CustomResource.new( :title=>"John").to_rest_chain
    resource.title.should == "John"
  end

  it "should find  and follow customer" do
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:status => 200, :body => customer.to_json)
    resource = CustomResource.new(item).to_rest_chain
    p resource.suggest
    resource.customer.customerId.should == 42
  end

  it "should find  create action" do
    stub_request(:get, "http://api.x.io/orders/42/items").to_return(:status => 200, :body => customer.to_json)
    resource = CustomResource.new(actions).to_rest_chain
    p resource.action( :create)
    resource.action( :create)["name"].should == "create"
  end

  it "should has totalCount" do
    hash = {
      "properties" => {
        "totalCount" => 3
      },
      "links" => [
        {
          "rel" => "users",
          "href" => "/users/"
        },
        {
          "rel" => "authenticate",
          "href" => "/users/authenticate"
        }
      ],
    }
    resource =  CustomResource.new(hash).to_rest_chain
    resource.totalCount.should == 3
  end

  it "should has totalCount by building resource throught RestChain.resource_class option" do
    RestChain.resource_class = CustomResource
    resource =  example_hash.to_rest_chain
    resource.should be_kind_of(CustomResource)
    resource.totalCount.should == 3
  end


  it "should build resource and respond to totalCount by setting the Client.resource_class as CustomResource" do
    Client.resource_class = CustomResource
    resource =  Client.build(example_hash)
    resource.should be_kind_of(CustomResource)
    resource.totalCount.should == 3
  end


  it "should  by building resource to_rest_chain method and context" do
   RestChain.resource_class = CustomResource
    resource =  example_hash.to_rest_chain(Client)
    resource.should be_kind_of(CustomResource)
    resource.totalCount.should == 3
  end


end
