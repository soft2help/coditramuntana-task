module Api
  class BaseController < ApplicationController
    include ActionController::HttpAuthentication::Basic::ControllerMethods
    include ActionController::HttpAuthentication::Token::ControllerMethods
    include ::AccessControl

    PAGINATION_PARAMS = [:page, :per_page, page: [:page, :per_page]].freeze
    ORDER_PARAMS = [:order, :sort].freeze

    DEFAULT_AUTHENTICATION_ACTIONS = [
      :authenticate_with_api_key,
      :extract_controller_metadata,
      :access_control_rules,
      :access_control_roles,
      :access_control_permissions,
      :validate_access_control
    ]

    READ_OPS = %i[index show].freeze
    WRITE_OPS = %i[create update destroy edit].freeze
    EXECUTE_OPS = %i[].freeze

    ROLES_ACCESS = {
      # index: %i[super_admin admin]
    }

    attr_reader :current_bearer, :current_api_key, :token
    rescue_from Api::Exception, with: :api_exception

    DEFAULT_AUTHENTICATION_ACTIONS.each do |action|
      before_action action
    end

    # adapt this code block in your controller to avoid authentication of access_controls
    # DEFAULT_AUTHENTICATION_ACTIONS.each do |action|
    #   skip_before_action action, only: [:index]
    # end

    # Defines the access control rules
    #
    # @return [Api::AccessControl::RequestRules] the request rules defined for current api key's access control rules
    def access_control_rules
      add_checker Api::AccessControl::RequestRules.new(request, current_api_key.access_control_rules)
    end

    def access_control_roles
      add_checker Api::AccessControl::Roles.new(self.class::ROLES_ACCESS[action.to_sym], current_bearer&.roles)
    end

    def access_control_permissions
      add_checker Api::AccessControl::Permissions.new(permission, operation, current_api_key&.permissions)
    end

    def search_permitted_params other_permitted_params
      params.permit(*PAGINATION_PARAMS, *ORDER_PARAMS, *other_permitted_params)
    end

    protected

    def authenticate_with_api_key
      authenticate_or_request_with_http_token do |token, options|
        @token = token
        @current_api_key = request.env["authenticated_by_middleware"] || ApiKey.check(token)
        @current_bearer = current_api_key&.bearer
      end
    end

    # Override rails default 401 response to return JSON content-type
    # with request for Bearer token
    # https://api.rubyonrails.org/classes/ActionController/HttpAuthentication/Token/ControllerMethods.html
    def request_http_token_authentication(realm = "", message = nil)
      own_realm_message = Setting.get("api", "realm")
      headers["WWW-Authenticate"] = %(Bearer realm="#{own_realm_message.tr('"', "")}") if token.blank?
      render json: Error.new("UNAUTHORIZED", "Unauthorized").as_json, status: :unauthorized
    end

    private

    def validation error_message = "validation errors"
      instance_model = yield

      if !instance_model.errors.empty?
        errors = []
        instance_model.errors.each do |error|
          errors << Api::Error.new(error.attribute.to_s, error.full_message)
        end
        Api::Errors.new errors
        raise Api::Exception.new "VALIDATION_ERRORS", error_message, 400, errors
      end
      instance_model
    end

    def api_exception(exception)
      render json: {errors: exception.errors.as_json}, status: exception.http_status_code, status_text: exception.message
    end

    def add_checker(checker)
      Api::AccessControl::Validator.instance.add(checker)
    end

    def validate_access_control
      validator = Api::AccessControl::Validator.instance
      if !validator.validate
        raise Api::Exception.new("Forbidden", "User forbidden Access", :forbidden, validator.errors)
      end

      true
    end
  end
end
