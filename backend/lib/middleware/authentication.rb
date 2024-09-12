module Middleware
  class Authentication
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      token = request.env["HTTP_AUTHORIZATION"]&.slice(7..-1) # Remove 'Bearer ' prefix
      if token && (api_key = authenticate_token(token))
        # Token is valid, store relevant information in env
        request.env["authenticated_by_middleware"] = api_key
      end
      @app.call(env) # Continue the middleware chain
    end

    private

    def authenticate_token(token)
      ApiKey.check(token)
    end
  end
end
