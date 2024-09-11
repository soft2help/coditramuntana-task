module Api
  module AccessControl
    class RequestRules < Api::AccessControl::Checker
      attr_reader :request, :user_access_control_rules, :checkers
      def initialize(request, user_access_control_rules, with_errors = true)
        super(with_errors)
        @request = request
        @user_access_control_rules = user_access_control_rules || {}
        get_checkers
      end

      def get_checkers
        @checkers = []
        user_access_control_rules.keys.each do |rule|
          @checkers << "Api::AccessControl::Rules::#{rule.to_s.camelize}".constantize.new(@request, user_access_control_rules[rule], with_errors)
        rescue NameError
        end
      end

      def validate
        @checkers.each do |checker|
          checker.add_validator validator if validator
          validate = checker.validate
          @errors += checker.errors if with_errors
          return false unless validate
        end
        true
      end
    end
  end
end
