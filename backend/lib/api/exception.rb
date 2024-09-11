module Api
  class Exception < StandardError
    attr_reader :code, :message, :http_status_code, :errors
    def initialize code, message, http_status_code, errors = []
      @code = code
      @message = message
      @http_status_code = http_status_code
      @errors = errors
    end

    def self.throw code, message, http_status_code
      raise Api::Exception.new(code, message, http_status_code, [Api::Error.new(code, message)])
    end
  end
end
