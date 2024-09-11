module Api
  module AccessControl
    class Validator
      def self.instance
        RequestStore.store[:per_request_singleton] ||= new
      end

      attr_reader :checkers
      attr_accessor :errors
      def initialize
        reset
      end

      def reset
        @checkers = []
        @errors = []
      end

      def add checker
        raise "Invalid checker type" unless checker.is_a?(Api::AccessControl::Checker)
        @checkers << checker
      end

      def validate
        @checkers.each do |checker|
          checker.add_validator self
          return false unless checker.validate
        end
        true
      end
    end
  end
end
