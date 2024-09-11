module Api
  module V1
    module Components
      module SecuritySchemes
        def self.specs
          {
            BearerAuth: {
              description: "JWT key necessary to use API calls",
              type: :http,
              scheme: :bearer,
              name: "Authorization",
              in: :header,
              bearerFormat: "JWT"
            }
          }
        end
      end
    end
  end
end
