module RestChain
  module API
    class Definition
      attr_reader :rules, :name, :lookup



      def lookup_rules
        rules.collect { |rule| rule if rule.lookup? }.compact
      end

      def non_lookup_rules
        rules.collect { |rule| rule unless rule.lookup? }.compact
      end

      def apply_rule(name, resource)
        rule = rules.detect { |rule| rule.name == name }
        rule.apply_on(resource) if rule
      end

      def suggestions_for(resource)
        rules.collect { |rule| rule.suggestions_for(resource) }.flatten.compact.uniq
      end

      protected

      def initialize(name)
        @name   = name
        @rules  = @safe_attributes = @shortcuts= []
        @lookup = Module.new { include Lookup }
      end

      class << self

        def define_lookup_method(name, &block)
          _lookup = @current_definition.lookup
          _lookup.send :define_method, name do |method_name=nil, *args, &method_block|
            block.call(self, method_name, *args, &method_block)
          end
        end


        def apply_rule(name, resource)
          rule = @current_definition.rules.detect { |rule| rule.name == name }
          rule.apply_on(resource)
        end


        def end_point(object={ }, &block)
          point = object.to_rest_chain.context.link_to(object)
          block_given? ? block.call(point) : point
        end


        def define(name, options={ }, &block)
          rule = Rule.new(name, options, &block)
          @current_definition.rules << rule
          rule
        end


        def describe(name, &block)
          @current_definition = self.new(name)
          API.add_definition @current_definition
          class_eval(&block)
        end

      end

    end


  end
end
