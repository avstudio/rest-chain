module RestChain
	module Adapters

		class TyphoeusAdapter < AbstractAdapter

			def get(url, options={ }, &block)
				request(:get, url, options, &block)
			end

			def put(url, options={ }, &block)
				request(:put, url, options, &block)
			end

			def post(url, options={ }, &block)
				request(:post, url, options, &block)
			end

			def delete(url, options={ }, &block)
				request(:delete, url, options, &block)
			end

			def options(url, options={ }, &block)
				request(:options, url, options, &block)
			end

			def head(url, options={ }, &block)
				request(:head, url, options, &block)
			end


			private

			def hydra
				@@hydra ||= Typhoeus::Hydra.new
			end

			#todo implement correctly parallel requests
			def request(method, url, options={ }, &block)
				RestChain.logger.info "RestChain:Typhoeus  method: #{method}  url: #{url}"
				params = request_options(options.merge(method: method))
				RestChain.logger.info "RestChain:Typhoeus  params: #{params} "
				request  = Typhoeus::Request.new(url, params)
				@@caller ||= request.object_id
				request.on_complete do |server_response|
					server_response_body = Response.parse(request, server_response)
					block_given? ? block.call(server_response_body) : server_response_body
				end
				hydra.queue request
				if @@caller == request.object_id
					@@caller = nil
					hydra.run
				end
				request.handled_response
			end


			def request_options(attributes={ })
				case attributes[:method]
					when :post, :put, :delete
						attributes.merge!({ body: MultiJson.dump(attributes.delete(:params) || { }) })
					else
						attributes.merge({ params: attributes[:params] || { } })
				end
			end

		end
	end
end
