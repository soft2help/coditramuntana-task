module BaseSearch
  class Order
    def initialize(scope, params, args)
      @args = args
      @scope = scope
      @sort_params = params[:sort] || params[:order] || ""
      @allowed_orders = args[:allowed_orders] || []
    end

    def apply
      @scope = @scope.order(safe_order)

      @scope
    end

    private

    def safe_order
      @safe_order = allowed_order
      @safe_order = @args[:default_order] if @safe_order.empty?
      @safe_order.merge({created_at: :desc}) unless @safe_order.has_key?(:created_at)
      @safe_order
    end

    def parsed_order
      @parsed_order ||= @sort_params.split(",").each_with_object({}) do |order, obj|
        if order.include?("_asc") || order.include?("_desc")
          key = order.rpartition("_").first
          value = order.rpartition("_").last
        else
          key = order.split("-").last
          value = (order[0] == "-") ? :desc : :asc
        end

        obj[key.to_sym] = value
      end
    end

    def allowed_order
      parsed_order.select do |key, _|
        @allowed_orders.map(&:to_sym).include?(key.to_sym)
      end
    end
  end
end
