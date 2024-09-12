module Api
  module V1
    module Components
      module Artists
        module QueryParameters
          def self.specs
            {}
              .merge(name)
              .merge(sort)
              .merge(order)
          end

          def self.name
            {
              name: {
                name: "filter[name]",
                in: :query,
                required: false,
                description: "Filter by name of artist (can be comma separated values for multiple)"
              }
            }
          end

          def self.sort
            {
              sort: {
                name: :sort,
                in: :query,
                schema: {
                  type: :string,
                  enum: %w[-created_at created_at -name name]
                },
                required: false,
                description: "Sort By de field that you want"
              }
            }
          end

          def self.order
            {
              order: {
                name: :order,
                in: :query,
                required: false,
                description: "Sort by multiple fields is an alternative to the sort parameter, like -created_at,name to sort by created_at desc and name asc"
              }
            }
          end
        end
      end
    end
  end
end
