describe "Rule" do
	let(:actions) { SIREN_YML['actions'].clone }
	let(:rule) { RestChain::API::Rule.new :actions,suggest:[:name] }

	it "should collect suggestions" do
    resource = actions.to_rest_chain
		rule.suggestions.should == [:name]
		rule.suggestions_for(actions.clone.to_rest_chain).should == [:create, :update]
    resource.suggest.should == [:create, :update]
	end

end
