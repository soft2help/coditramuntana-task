module BaseSearch
  class Pagination
    def initialize(scope, params, args)
      @args = args
      @scope = scope
      @params = params || {}
    end

    def apply
      @scope.page(page).per(per_page || 10)
    end

    def page
      page_param ? page_param.to_i : @args[:default_page]
    end

    def per_page
      per_page = per_page_param || @args[:default_per_page]
      (per_page.to_i <= @args[:max_per_page]) ? per_page.to_i : @args[:max_per_page]
    end

    def page_param
      @params[:page].is_a?(String) ? @params[:page] : @params.dig(:page, :page)
    rescue
      nil
    end

    def per_page_param
      @params[:per_page].is_a?(String) ? @params[:per_page] : @params.dig(:page, :per_page)
    rescue
      nil
    end
  end
end
