module RestChain
  module API
    class Rule

      attr_reader :name, :lookup, :suggestions

      def initialize(name, options={ }, &block)
        @lookup      = options[:lookup]
        @name        = name
        @block       = block
        @suggestions = [options[:suggest]].flatten.compact
      end

      def lookup?
        @lookup
      end

      def suggestions_for(resource)
        return [] unless resource.attribute?(name)
        @suggestions.inject([]) do |out,suggestion|
          out += resource.chain_path([name, suggestion].join('.'), nil, parent: false, collect: true)
          out
        end.uniq.map(&:to_sym)
      end


      def apply_on(resource, method_name=nil, *args, &block)
        @block.call(resource, method_name, *args, &block)
      end


    end
  end
end
