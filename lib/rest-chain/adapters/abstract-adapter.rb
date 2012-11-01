module RestChain
	module Adapters
		class AbstractAdapter

			def initialize(*)

			end

			def get(*)
				raise NotImplementedError, "This should be implemented by subclass"
			end

			def put(*)
				raise NotImplementedError, "This should be implemented by subclass"
			end


			def post(*)
				raise NotImplementedError, "This should be implemented by subclass"
			end

			def delete(*)
				raise NotImplementedError, "This should be implemented by subclass"
			end

			def options(*)
				raise NotImplementedError, "This should be implemented by subclass"
			end

			def head(*)
				raise NotImplementedError, "This should be implemented by subclass"
			end

		end
	end
end
