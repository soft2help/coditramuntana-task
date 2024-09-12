module BaseSearch
  class Filter
    attr_accessor :filters

    def initialize(scope, params, args)
      @args = args
      @scope = scope
      @params = params
      @allowed_filters = args[:allowed_filters]
      @filters = safe_filters
    end

    def apply
      filters.each do |item|
        filter(item[:field], item[:filter_type], item[:value])
      end

      @scope
    end

    private

    def safe_filters
      safe_filters_list = []

      filter_params.keys.each do |field|
        allowed_filter = @allowed_filters.find { |item| item[:field] == field }

        # next if filter field not allowed
        next if allowed_filter.nil?

        allowed_filter_types, params_filter_types = if allowed_filter[:type].is_a?(Array)
          if filter_params.to_unsafe_hash[field].is_a?(Hash)
            [allowed_filter[:type], filter_params[field].keys.map(&:to_sym)]
          else
            [allowed_filter[:type], [allowed_filter[:type]]]
          end
        else
          [[allowed_filter[:type]], [allowed_filter[:type]]]
        end

        # remove filter types not allowed
        filtered_filter_types = (params_filter_types & allowed_filter_types)

        filtered_filter_types.each do |filter_type|
          # backwards compatibility for ?filter[field]=xpto
          # new format: ?filter[field][filter_type]=xyz
          value = filter_params.to_unsafe_hash[field].is_a?(Hash) ? filter_params[field][filter_type] : filter_params[field]

          safe_filters_list.push({
            field: field,
            filter_type: filter_type,
            value: value
          })

          # only applies first filter if allow_multiple is falsey
          break unless allowed_filter[:allow_multiple]
        end
      end

      safe_filters_list
    end

    def filter_params
      @filter_params ||= @params.has_key?(:filter) ? @params[:filter] : @params
    end

    def filter(field, filter_type, value)
      send(:"filter_#{filter_type}", field, value)
    end

    def filter_value(field, value)
      @scope = @scope.where("#{field}": value)
    end

    def filter_array(field, value)
      @scope = @scope.where("#{field}": value.to_s.include?(",") ? value.to_s.split(",") : [value])
    end
  end
end
