describe "RestChain" do
  before(:all) do
    RestChain.use :siren
  end

  describe "Error" do
    it "should raise error" do
      stub_request(:get, "http://example.com").to_return(:body =>"",:status=>404)
      expect{ {'href'=>'http://example.com','rel'=>'self' }.to_rest_chain.self_link}.to raise_error(RestChain::Error::NotFound)
    end

  end
end
