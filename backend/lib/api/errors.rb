module Api
  class Errors
    attr_reader :errors
    def initialize errors = []
      @errors = errors
    end

    def add error
      errors << error if error.is_a? Api::Error
    end

    def as_json
      {
        errors: errors.map(&:as_json)
      }
    end
  end
end
