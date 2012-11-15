module RestChain
  #todo improve response handling
  module Response
    extend self
    #status codes and status switch borrowed from Restfulie
    def parse(request, response)
      case response.code
      when 100..299
        parse_response_body(request, response)
      when 300..399
        raise Error::Redirection.new(request, response.body)
      when 400
        raise Error::BadRequest.new(request, response.body)
      when 401
        raise Error::Unauthorized.new(request, response.body)
      when 403
        raise Error::Forbidden.new(request, response.body)
      when 404
        raise Error::NotFound.new(request, response.body)
      when 405
        raise Error::MethodNotAllowed.new(request, response.body)
      when 407
        raise Error::ProxyAuthenticationRequired.new(request, response.body)
      when 409
        raise Error::Conflict.new(request, response.body)
      when 410
        raise Error::Gone.new(request, response.body)
      when 412
        raise Error::PreconditionFailed.new(request, response.body)
      when 402, 406, 408, 411, 413..421, 423..499
        raise Error::ClientError.new(request, response.body)
      when 422
        parse_response_body(request, response)
      when 501
        raise Error::NotImplemented.new(request, response.body)
      when 500, 502..599
        raise Error::ServerError.new(request, response.body)
      else
        raise Error::UnknownError.new(request, response.body)
      end
    end

    private

    def parse_response_body(request, response)
      begin
        MultiJson.load(response.body)
      rescue
        raise Error::SerializationError.new(request, response.body)
      end
    end

  end
end
