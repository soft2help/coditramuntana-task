module Api
  module AccessControl
    class Roles < Api::AccessControl::Checker
      attr_reader :action_allowed_roles, :user_roles
      ALLOW_ACCESS_IF_ROLES_TO_ACTION_NOT_SET = true
      ALLOW_ACCESS_IF_USER_DONT_HAVE_ROLES = false

      # maybe this should be more dynamic, more highest number has more access level
      HIERARCHY_ROLES = {
        super_admin: 4,
        admin: 3,
        user: 2,
        basic: 1
      }

      def initialize(action_allowed_roles, user_roles, with_errors = true)
        super(with_errors)
        @action_allowed_roles = (action_allowed_roles || []).map(&:to_sym)
        @user_roles = (user_roles || []).map(&:to_sym)
        @with_errors = with_errors
      end

      def error_codes
        {
          roles_not_set: {code: "ROLES-TO-ACTION-NOT-DEFINED", message: "Roles not set to action"},
          user_roles_not_set: {code: "USER-ROLES-NOT-DEFINED", message: "User roles not set"},
          user_dont_have_allowed_roles: {code: "USER-DONT-HAVE-ROLES-TO-ACTION", message: "User dont have allowed roles to action"}
        }
      end

      def validate
        if action_allowed_roles.empty?
          add_error :roles_not_set if !ALLOW_ACCESS_IF_ROLES_TO_ACTION_NOT_SET
          return ALLOW_ACCESS_IF_ROLES_TO_ACTION_NOT_SET
        end

        if user_roles.empty?
          add_error :user_roles_not_set if !ALLOW_ACCESS_IF_USER_DONT_HAVE_ROLES
          return ALLOW_ACCESS_IF_USER_DONT_HAVE_ROLES
        end

        if !is_allowed?
          add_error :user_dont_have_allowed_roles
          return false
        end

        true
      end

      def is_allowed?
        (user_roles & action_allowed_roles != []) ||
          greater_than?(
            highest_role(user_roles),
            lowest_role(action_allowed_roles)
          )
      end

      def highest_role(roles)
        roles.max_by { |role| HIERARCHY_ROLES[role] }
      end

      def lowest_role(roles)
        roles.min_by { |role| HIERARCHY_ROLES[role] }
      end

      def greater_than?(base_role, other_role)
        HIERARCHY_ROLES[base_role] > HIERARCHY_ROLES[other_role]
      end
    end
  end
end
