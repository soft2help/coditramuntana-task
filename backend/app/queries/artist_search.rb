class ArtistSearch < BaseSearch::Search
  ALLOWED_FILTERS = [
    {field: "name", type: :value}
  ]

  ALLOWED_ORDERS = %i[name created_at updated_at]

  DEFAULT_ORDER = {created_at: :desc}

  def initialize(params)
    super(params, Artist)
  end
end
