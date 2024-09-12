module Api
  module V1
    module Components
      module Artists
        module Schemas
          def self.index
            {
              ArtistsIndex: {
                type: :object,
                properties: {
                  data: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        id: {type: :string, example: "64e34b239a0d871b61aab5cc"},
                        type: {type: :string, example: "artists"},
                        attributes: {"$ref" => "#/components/schemas/ArtistsAttributes"} # Custom attributes for this endpoint
                      }
                    }
                  },
                  meta: {"$ref" => "#/components/schemas/PaginationInfo"} # Reuse the Meta schema
                },
                required: ["data", "meta"]
              }
            }
          end

          def self.index_attributes
            {
              ArtistsAttributes: {
                type: :object,
                properties: {
                  name: {type: :string, example: "Golf"},
                  created_at: {type: :string, example: "2024-09-06T08:40:27.821Z"},
                  updated_at: {type: :string, example: "2024-09-06T08:40:27.821Z"}

                },
                required: ["name", "created_at", "updated_at"]
              }
            }
          end

          def self.show_attributes
            {
              ArtistsShow: {
                type: :object,
                properties: {
                  data: {
                    type: :object,
                    properties: {
                      id: {type: :string, example: "64e34b239a0d871b61aab5cc"},
                      type: {type: :string, example: "artists"},
                      attributes: {"$ref" => "#/components/schemas/ArtistsAttributes"} # Custom attributes for this endpoint
                    }
                  }
                },
                required: ["data"]
              }
            }
          end
        end
      end
    end
  end
end
