module Api
  module V1
    module Components
      module QueryParameters
        def self.specs
          {}
            .merge(page)
            .merge(per_page)
        end

        def self.page
          {
            page: {
              name: "page[page]",
              in: :query,
              type: :integer,
              required: false,
              description: "Page number for pagination",
              example: 1
            }
          }
        end

        def self.per_page
          {
            per_page: {
              name: "page[per_page]",
              in: :query,
              type: :integer,
              required: false,
              description: "Number of items per page",
              example: 10
            }
          }
        end
      end
    end
  end
end
