module RestChain
  class Collection
    include Enumerable
    attr_reader :context

    def initialize(collection)
      @collection = collection || []
      class << @collection
        attr_reader :context
      end
    end

    def original
      self
    end

    def suggest
      collect(&:suggest).flatten.uniq
    end

    def read_attribute(name)
      send name
    end

    def attribute?(name)
      false
    end


    def first
      resource = @collection.first
      resource.to_rest_chain(context) if resource
    end

    def last
      resource = @collection.last
      resource.to_rest_chain(context) if resource
    end


    def lazy?
      @collection.any?(&:lazy?)
    end

    def loaded?
      !lazy?
    end

    #todo
    def follow(name_or_url= nil, params={ })
      raise NotImplementedError, "Currently not supported form collection"
    end


    def inspect
      return super unless defined?(AwesomePrint)
      ap self
    end


    def each(&block)
      @collection.each do |el|
        block.call(el.to_rest_chain(context))
      end
    end

    def chain_path(*args)
      @collection.instance_variable_set(:@context,self.context)
      @collection.chain_path(*args)
    end


    #nightmare
    def method_missing(name, *args, &block)
      out = nil
      each do |el|
        begin
          out = el.send(name)
          out ? break : next
        rescue
          next
        end
      end
      out
    end

  end
end
