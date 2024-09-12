class Api::V1::AuthController < Api::BaseController
  include PaginationMeta
  include ReadOnly

  # public access
  DEFAULT_AUTHENTICATION_ACTIONS.each do |action|
    skip_before_action action, only: [:login]
  end

  # in this case doesnt make sense because we are using sqlite3
  # around_action :use_read_only_databases, only: [:index, :show]

  ## only allow on token per session
  def login
    user = User.where(email: login_params[:email]).first

    if !(user && user.authenticate(login_params[:password]))
      Api::Exception.throw("USER_NOT_FOUND", "Given User was not found", 404)
    end

    user.api_keys.where(name: "login")&.first&.delete
    api_key = ApiKey.create(bearer: user, name: "login")

    render json: {token: api_key.raw_token},
      adapter: :json_api,
      status: :ok
  end

  def logout
    @current_bearer.api_keys.where(name: "login")&.first&.delete
    head :no_content
  end

  private

  def login_params
    @auth_param ||= params.require(:data).require(:attributes).permit(
      :email, :password
    )
  end
end
