class Report
  include Callable

  attr_reader :page, :per_page, :order_field
  def initialize page, per_page, order_field = "lps.name"
    @page = page
    @per_page = per_page
    @order_field = order_field
  end

  def call
    cache_key = ReportCacheControl.report_cache_key page: page, per_page: per_page, order_field: order_field
    # Fetch data from Redis cache if it exists, otherwise calculate and store it

    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      data = Lp.left_joins(:artist, songs: :authors)
        .select("lps.id,
                  lps.name as lp_name,
                  artists.name as artist_name,
                  COUNT(DISTINCT songs.id) as song_count,
                  COALESCE(GROUP_CONCAT(DISTINCT authors.name), '') as authors_list")
        .group("lps.id, artists.id")
        .order(order_field)
        .page(page)
        .per(per_page)
        .to_a

      [data, page, per_page, Lp.count]
    end
  end
end
