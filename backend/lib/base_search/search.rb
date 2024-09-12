module BaseSearch
  class Search
    attr_accessor :params, :filters, :orders, :pagination

    MAX_PER_PAGE = 48
    DEFAULT_PER_PAGE = 24
    DEFAULT_PAGE = 1
    DEFAULT_ORDER = {created_at: :desc}
    ALLOWED_FILTERS = [].freeze
    ALLOWED_ORDERS = [].freeze
    ALLOW_DISABLE_PAGINATION = false

    def initialize(params, klass)
      @params = params
      @scope = klass
    end

    def self.allowed_filters_params
      [filter:
        self::ALLOWED_FILTERS.map { |filter| filter[:field].to_sym }]
    end

    def search
      @scope = apply_filters
      @scope = apply_orders

      return @scope.to_a if pagination_disabled?

      total = @scope.count
      @scope = apply_pagination

      [@scope.to_a, pagination.page, pagination.per_page, total]
    end

    def apply_filters
      @filters = Filter.new(
        @scope,
        @params,
        {
          allowed_filters: self.class::ALLOWED_FILTERS
        }
      )
      @filters.apply
    end

    def apply_orders
      @orders = Order.new(
        @scope,
        @params,
        {
          allowed_orders: self.class::ALLOWED_ORDERS,
          default_order: self.class::DEFAULT_ORDER
        }
      )
      @orders.apply
    end

    def apply_pagination
      @pagination = Pagination.new(
        @scope,
        @params,
        {
          default_page: self.class::DEFAULT_PAGE,
          default_per_page: self.class::DEFAULT_PER_PAGE,
          max_per_page: self.class::MAX_PER_PAGE
        }
      )
      @pagination.apply
    end

    def pagination_disabled?
      self.class::ALLOW_DISABLE_PAGINATION && params.dig(:options, :disable_pagination)
    end
  end
end
