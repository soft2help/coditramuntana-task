module Api
  module V1
    module Components
      module Responses
        def self.specs
          {}
            .merge(forbidden)
            .merge(unauthorized)
        end

        def self.forbidden
          {
            "403": {
              description: "Forbidden",
              content: {
                "application/json": {
                  schema: {
                    "$ref": "#/components/schemas/Error"
                  }
                }
              }
            }
          }
        end

        def self.unauthorized
          {
            "401": {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: {
                    "$ref": "#/components/schemas/Error"
                  }
                }
              }
            }
          }
        end
      end
    end
  end
end
