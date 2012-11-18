module RestChain
  module Inflection

    def inflect!(object)
      return object unless object.respond_to?(:to_rest_chain)
      inflected = object.to_rest_chain
      inflected.instance_variable_set(:@context, self.context)
      inflected
    end

  end
end
