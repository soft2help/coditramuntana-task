class Api::V1::LpsController < Api::BaseController
  include PaginationMeta
  include ReadOnly
  READ_OPS = %i[].freeze
  WRITE_OPS = %i[].freeze
  EXECUTE_OPS = %i[].freeze
  ROLES_ACCESS = {
    index: %i[user],
    show: %i[user],
    create: %i[user],
    update: %i[user],
    destroy: %i[admin]
  }.freeze

  before_action :set_lp, only: %i[show update destroy]

  # in this case doesnt make sense because we are using sqlite3
  # around_action :use_read_only_databases, only: [:index, :show]

  def index
    collection, page, per_page, total = LpSearch.new(search_params).search

    render json: collection,
      each_serializer: Api::V1::LpSerializer,
      adapter: :json_api,
      meta: pagination_dict(page, per_page, total),
      status: :ok
  end

  def show
    render json: @lp,
      serializer: Api::V1::LpSerializer,
      adapter: :json_api,
      status: :ok
  end

  def create
    lp = validation do
      ::Lp.create(lp_params)
    end

    render json: lp,
      serializer: Api::V1::LpSerializer,
      adapter: :json_api,
      status: :ok
  end

  def update
    lp = validation do
      @lp.update(lp_params)
      @lp
    end

    render json: lp,
      serializer: Api::V1::LpSerializer,
      adapter: :json_api,
      status: :ok
  end

  def destroy
    @lp.destroy
    head :no_content
  end

  private

  def lp_params
    params.require(:data).require(:attributes).permit(
      :name, :description, :artist_id
    )
  end

  def search_params
    @search_params ||= search_permitted_params(LpSearch.allowed_filters_params)
  end

  def set_lp
    @lp = Lp.where(id: params[:id]).first

    if !@lp
      Api::Exception.throw("LP_NOT_FOUND", "Given lp was not found", 404)
    end

    @lp
  end
end
