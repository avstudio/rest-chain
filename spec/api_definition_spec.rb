describe "API Rules" do

  before do
    RestChain::API.clear :demo
  end

  describe "Interface" do

    it "should create 1 definition" do
      RestChain::API::Definition.describe :demo do
        define :properties do |resource|
          resource.properties.each { |k, v| resource.set(k, v) }
        end
      end
      RestChain::API.definition_for(:demo).rules.count.should ==1
      RestChain::API.definition_for(:demo).rules.first.name.should == :properties
    end


    it "should create 2 descriptions" do
      RestChain::API::Definition.describe :demo do
        define :properties do |resource|
          resource.properties.each { |k, v| resource.set(k, v) }
        end
        define :entities do |resource|
          resource.properties.each { |k, v| resource.set(k, v) }
        end
      end
      rules = RestChain::API.definition_for(:demo).rules
      rules.count.should ==2
      rules.first.name.should == :properties
      rules.last.name.should == :entities
    end

    it "should join rules" do
      RestChain::API::Definition.describe :demo do
        define :properties do |resource|
          resource['properties'].each { |k, v| resource[k] = v }
        end
        define :some do |resource|
          apply_rule :properties, resource
        end
      end
      resource = { 'properties' => { "name" => "mile" } }
      RestChain::API.definition_for(:demo).rules.last.apply_on(resource,:some_method)
      resource.should have_key('name')
    end

    it "should skip rule" do
      RestChain::API::Definition.describe :demo do
        define :properties do |resource|
          next
          resource['properties'].each { |k, v| resource[k] = v }
        end
      end
      resource = { 'properties' => { "name" => "mile" } }
      RestChain::API.definition_for(:demo).rules.first.apply_on(resource,:some_method)  rescue nil
      resource.should_not have_key('name')
    end

    describe "Suggestions" do
      let(:item) { SIREN_YML['item'].dup }

      it "should suggest :user,:create,:customer" do
        RestChain::API::Definition.describe :demo do
          define :actions, suggest: :name do |resource|
          end
          define :entities, suggest: :rel do |resource|
          end
        end
        resource = item.to_rest_chain
        resource.suggestions.should == [:user, :customer, :items, :owner, :create, :update]
      end
    end


  end
end
