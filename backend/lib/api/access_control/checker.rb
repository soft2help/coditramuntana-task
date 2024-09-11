module Api
  module AccessControl
    class Checker
      attr_reader :validator, :with_errors, :errors
      def initialize(with_errors)
        @with_errors = with_errors
        @errors = []
      end

      def add_validator validator
        @validator = validator
      end

      private

      def add_error error_type
        if with_errors
          @errors << error_codes[error_type]
          @validator.errors << error_codes[error_type] if validator
        end
      end

      def check_it error_type
        valid = yield
        add_error error_type if !valid && with_errors
        valid
      end

      def validate
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def error_codes
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
