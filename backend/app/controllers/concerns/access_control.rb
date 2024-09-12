module AccessControl
  extend ActiveSupport::Concern

  included do
    attr_reader :prefix, :version, :namespace, :resource, :action, :operation, :permission, :allowed_roles
  end

  private

  def extract_controller_metadata
    # Split the controller's class name by '::' and remove the last 'Controller' part
    parts = self.class.name.split("::")
    @resource = parts.pop.sub("Controller", "")
    # Assign the extracted parts to instance variables
    @prefix = parts[0..1].join("::")
    @version = parts[1]
    @namespace = parts[2]
    @action = action_name # Provided by Rails, no need to extract

    @permission = "#{prefix}::#{namespace}::#{resource}::#{action}"

    @operation = if self.class::READ_OPS.include?(@action.to_sym)
      "r"
    elsif self.class::WRITE_OPS.include?(@action.to_sym)
      "w"
    elsif self.class::EXECUTE_OPS.include?(@action.to_sym)
      "x"
    end

    # #self.class::ROLES_ACCESS[action.to_sym].include?(current_bearer&.roles || [])

    # Optionally, log or use these variables as needed
    Rails.logger.debug "Version: #{@version}, Namespace: #{@namespace}, Resource: #{@resource}, Action: #{@action}"
  end
end
