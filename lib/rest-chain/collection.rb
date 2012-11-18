module RestChain
  class Collection
    include Enumerable
    include Inflection

    attr_reader :context

    def initialize(collection)
      @collection = collection || []
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
      inflect! @collection.first
    end

    def last
      inflect! @collection.last
    end

    def lazy?
      @collection.any?(&:lazy?)
    end

    def loaded?
      !lazy?
    end

    #todo
    def follow(name_or_url= nil, params={ })
      raise NotImplementedError, "Currently not supported from collection"
    end

    def +(arr)
      @collection + arr
    end

    def -(arr)
      @collection - arr
    end

    def to_ary
      @collection
    end

    def inspect
      return super unless defined?(AwesomePrint)
      ap "RestChain Collection"
      ap @collection
    end

    def each(&block)
      @collection.each do |el|
        block.call(inflect!(el))
      end
    end

    def chain_path(*args)
      inflect! @collection.chain_path(*args)
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
