require 'rest-chain/api/rule'
require 'rest-chain/api/lookup'
require 'rest-chain/api/definition'

module RestChain
  module API
    extend self

    attr_reader :definitions
    @definitions = { }

    def definition_for(name)
      @definitions[name]
    end

    def add_definition(definition)
      @definitions[definition.name] = definition
    end

    def clear(name=nil)
      @definitions = { } unless name
      @definitions.delete(name)
    end

  end
end

