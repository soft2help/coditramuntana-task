module Api
  module V1
    module Components
      module Artists
        module CreateParameters
          def self.specs
            {}
              .merge(name)
          end

          def self.name
            {
              artist: {
                name: :artist,
                in: :body,
                schema: {
                  type: :object,
                  properties: {
                    data: {
                      type: :object,
                      properties: {
                        attributes: {
                          type: :object,
                          properties: {
                            name: {type: :string}
                          },
                          required: ["name"]
                        }
                      },
                      required: ["attributes"]
                    }
                  },
                  required: ["data"]
                }
              }
            }
          end
        end
      end
    end
  end
end
