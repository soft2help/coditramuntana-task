class Api::V1::ArtistsController < Api::BaseController
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

  before_action :set_artist, only: %i[show update destroy]

  # in this case doesnt make sense because we are using sqlite3
  # around_action :use_read_only_databases, only: [:index, :show]

  def index
    collection, page, per_page, total = ArtistSearch.new(search_params).search

    render json: collection,
      each_serializer: Api::V1::ArtistSerializer,
      adapter: :json_api,
      meta: pagination_dict(page, per_page, total),
      status: :ok
  end

  def show
    render json: @artist,
      serializer: Api::V1::ArtistSerializer,
      with_lp_count: true,
      adapter: :json_api,
      status: :ok
  end

  def create
    artist = validation do
      ::Artist.create(artist_params)
    end

    render json: artist,
      serializer: Api::V1::ArtistSerializer,
      adapter: :json_api,
      status: :ok
  end

  def update
    artist = validation do
      @artist.update(artist_params)
      @artist
    end

    render json: artist,
      serializer: Api::V1::ArtistSerializer,
      adapter: :json_api,
      status: :ok
  end

  def destroy
    @artist.destroy
    head :no_content
  end

  private

  def artist_params
    params.require(:data).require(:attributes).permit(
      :name, :description
    )
  end

  def search_params
    @search_params ||= search_permitted_params(ArtistSearch.allowed_filters_params)
  end

  def set_artist
    @artist = Artist.where(id: params[:id]).first

    if !@artist
      Api::Exception.throw("ARTIST_NOT_FOUND", "Given artist was not found", 404)
    end

    @artist
  end
end
