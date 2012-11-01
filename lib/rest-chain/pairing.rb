module RestChain
  module Pairing
    extend self


    def pair(name, client)
      raise ArgumentError, "U can't pair object which is not  the RestChain resource!" unless client.kind_of?(Resource) ||  client.kind_of?(Collection)
      pairs[name] = client
      self
    end


    def pairs
	    @pairs       ||={ }
    end

    def unpair(name)
	    pairs.delete(name)
      self
    end


    def unpair_all
	    @pairs = {}
    end


  end
end
