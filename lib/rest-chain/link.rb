module RestChain
  class Link
    attr_accessor :href, :context, :type, :rel, :template, :headers, :request_method, :params, :headers

    def initialize(context, attributes={ })
      p attributes
      attributes ||={ }
      attributes = attributes.inject({ }) { |el, (k, v)| el[k.to_s] = v; el } #for any case
      @href      = attributes['href']
      @context   = context
      @rel       = attributes['rel']
      @type      = attributes['type']
      @request_method = (attributes['method'] || attributes['request_method'] || 'get').downcase.to_sym
      @params   = { }
      @template = attributes['template']
      @headers  = context.headers.dup
      @headers[:"Content-Type"] = @type if @type
    end

    def params
      (@params ||= { })
    end

    def href
      raise(BrokenChainError,"Oops. The chain is broken :(. Invalid url. Got nil") unless @href
      return @href unless URI(@href).relative?
      URI.join(context.entry_point, @href).to_s
    end


    def url
      if  @template
        expanded = URITemplate.new(href.dup).expand(@params)
        URI.parse(expanded).to_s
      else
        URI.parse(href).to_s
      end

    end

    def adapter
      @adapter ||= context.adapter
    end

    def follow(url_params={ }, &block)
      @params = url_params.dup if url_params
      adapter.send(request_method, url, { :params => params, :headers => @headers[:headers] }, &block).to_rest_chain(context)
    end
  end
end
