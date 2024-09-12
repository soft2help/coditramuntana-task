class LpSearch < BaseSearch::Search
  attr_reader :params
  ALLOWED_FILTERS = [
    {field: "name", type: :value},
    {field: "artist_name", type: :array}

  ]

  ALLOWED_ORDERS = %i[name created_at updated_at]

  DEFAULT_ORDER = {created_at: :desc}

  def initialize(params)
    @params = params
    collection = on_init
    super(params, collection)
  end

  def on_init
    if params.dig(:filter, :artist_name)
      artist_names = params[:filter][:artist_name].split(",")
      params[:filter].delete(:artist_name)
      return Lp.joins(:artist).where(artists: {name: artist_names})
    end

    Lp
  end
end
