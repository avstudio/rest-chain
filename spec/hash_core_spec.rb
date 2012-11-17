describe "HashCoreExt" do
  it "shoud retur nmatch" do
    hash = {
      "rel"=>"customer",
      "href"=>"http://api.x.io/orders/42/items",
      "properties"=>{"orderNumber"=>42, "item_number"=>42, "itemCount"=>42, "status"=>"pending"},
      "links"=>[{"rel"=>"next", "href"=>"http://api.x.io/orders/42"},
                {"rel"=>"prev", "href"=>"http://api.x.io/orders/42"}],
      "actions"=>[{
                    "name"=>"create", "method"=>"POST", "href"=>"http://api.x.io/orders/42/items",
                    "type"=>"application/x-www-form-urlencoded",
                    "fields"=>[{
                               "name"=>"order_id", "type"=>"Integer"}
                               ]}
                  ]
    }

    hash.chain_path("rel", "customer", {:parent=>true}).should == hash
    hash.chain_path("rel", "customer", {:parent=>false}).should ==  "customer"
    hash.chain_path("links.rel", "customer", {:parent=>true}).should be_nil
    hash.chain_path("links.rel", "next", {:parent=>true}).should == {"rel"=>"next", "href"=>"http://api.x.io/orders/42"}
    hash.chain_path("links.rel", "next", {:parent=>false}).should == "next"
  end
end
