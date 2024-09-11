module Api
  class Error
    attr_reader :code, :message, :details
    def initialize code, message, details = nil
      @code = code
      @message = message
      @details = details
    end

    def as_json
      base = {
        code: code,
        message: message
      }
      if details.present?
        base[:details] = details
      end
      base
    end
  end
end
