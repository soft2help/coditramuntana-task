module Api
  module AccessControl
    class Permissions < Api::AccessControl::Checker
      ALLOW_ACTION_IF_NO_PERMISSION_SET = true
      attr_reader :context, :operation, :token_permissions
      def initialize(context, operation, token_permissions)
        @context = context
        @operation = operation
        @token_permissions = token_permissions
      end

      def error_codes
        {
          permission_denied: {code: "PERMISSION-DENIED", message: "Permission denied"},
          another_permission_set: {code: "PERMISSION-NOT-DEFINED", message: "Permission not defined"}
        }
      end

      def validate
        n_segments = context.split("::").count

        allowed = ALLOW_ACTION_IF_NO_PERMISSION_SET
        (n_segments - 1).downto(0) do |current|
          current_permission = context.split("::")[0..current].join("::")

          next if !(permissions = token_permissions[current_permission]) # nil |r|r,w|r,w,x|-r,w,x

          ops = permissions.split(",")
          if ops.include?(operation)
            allowed = true
            break
          end

          not_allowed = ops.include?("-#{operation}")
          if not_allowed
            add_error :permission_denied
            allowed = false
            break
          end

          another_ops = ops.any? { |op| !op.include?("-") }

          if another_ops
            add_error :another_permission_set
            allowed = false
            break
          end
        end
        allowed
      end

      def self.check(context, operation, token_permissions)
        new(context, operation, token_permissions).validate
      end
    end
  end
end
