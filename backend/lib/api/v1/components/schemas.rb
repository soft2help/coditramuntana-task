module Api
  module V1
    module Components
      module Schemas
        def self.specs
          {}
            .merge(default_error)
            .merge(default_errors)
            .merge(meta_pagination)
            .merge(generic_attributes)
            .merge(data_item)
            .merge(data_array)
        end

        def self.default_error
          {
            Error: {
              type: "object",
              properties: {
                code: {type: "string"},
                message: {type: "string"},
                details: {
                  type: "array",
                  items: {type: "string"}
                }
              },
              required: ["code", "message"]
            }
          }
        end

        def self.default_errors
          {
            Errors: {
              type: :object,
              properties: {
                errors: {
                  type: :array,
                  items: {"$ref" => "#/components/schemas/Error"}
                }
              },
              required: ["errors"]
            }
          }
        end

        def self.meta_pagination
          {

            PaginationInfo: {
              type: :object,
              properties: {
                current_page: {type: :integer, example: 1},
                next_page: {type: :integer, example: 1, nullable: true},
                prev_page: {type: :integer, example: 1, nullable: true},
                total_pages: {type: :integer, example: 1},
                total_count: {type: :integer, example: 2}
              },
              required: ["current_page", "total_pages", "total_count"]
            }
          }
        end

        def self.generic_attributes
          {
            GenericAttributes: {
              type: :object,
              properties: {
                uid: {type: :integer, example: 18},
                name: {type: :string, example: "Playoff manual"}
              },
              # Example of making it extendable
              additionalProperties: true
            }
          }
        end

        def self.data_item
          {
            DataItem: {
              type: :object,
              properties: {
                id: {type: :string, example: "64e34b239a0d871b61aab5cc"},
                type: {type: :string, example: "playoffs"},
                attributes: {"$ref" => "#/components/schemas/GenericAttributes"}
              },
              required: ["id", "type", "attributes"]
            }
          }
        end

        def self.data_array
          {
            DataArray: {
              type: :object,
              properties: {
                data: {
                  type: :array,
                  items: {"$ref" => "#/components/schemas/DataItem"}
                },
                meta: {
                  type: :object,
                  item: {"$ref" => "#/components/schemas/PaginationInfo"}
                }
              },
              required: ["data", "meta"]
            }
          }
        end
      end
    end
  end
end
