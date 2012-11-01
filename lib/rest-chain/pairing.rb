module RestChain
  module Pairing
    extend self

    attr_reader :pairs

    def pair(name, client)
      raise ArgumentError, "U can't pair object which is not  the RestChain resource!" unless client.kind_of?(Resource) ||  client.kind_of?(Collection)
      @pairs       ||={ }
      @pairs[name] = client
      self
    end

    def unpair(name)
      @pairs ||={ }
      @pairs.delete(name)
      self
    end


    def unpair_all
      @pairs = {}
    end


  end
end
