require "swagger_helper"

RSpec.describe "/v1/artists", type: :request, openapi_spec: "v1/swagger.yaml" do
  include_context "with clean redis"
  include_context "authentication setup"

  describe "list available artists" do
    context "check authentication actions" do
      it "[NOT AUTHENTICATED]" do
        get "/v1/artists"
        expect(response.status).to eq(401)
      end

      it "[AUTHENTICATED] USER WITHOUT EXPECTED ROLE " do
        get "/v1/artists", headers: {Authorization: "Bearer #{api_key_user_basic.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].first["code"]).to eq("USER-DONT-HAVE-ROLES-TO-ACTION")
      end

      it "[AUTHENTICATED] access control rules [Header Value Check]" do
        get "/v1/artists", headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "HEADER-VALUE-NOT-VALID" }).to be_truthy
      end

      it "[AUTHENTICATED] access control rules VALID [Header Value Check]" do
        get "/v1/artists", headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}", "X-Custom-Header": "Test"}
        expect(response.status).to eq(200)
      end

      it "[AUTHENTICATED] ip control rules [INVALID IP ACCESS]" do
        get "/v1/artists", headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "1.1.1.1"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "IP-ADDRESS-NOT-ALLOWED" }).to be_truthy
      end

      it "[AUTHENTICATED] ip control rules [VALID IP ACCESS]" do
        create_list(:artist, 25)
        get "/v1/artists", headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "172.25.94.167"}
        expect(response.status).to eq(200)
      end
    end
  end

  path "/v1/artists" do
    get("list of available Artists") do
      description "List Available Artists"
      operationId "listArtists"
      tags "USER"
      security [BearerAuth: []]

      Api::V1::Components::Artists::QueryParameters.specs.each do |param, spec|
        parameter spec
      end

      [:page, :per_page].each do |param|
        parameter Api::V1::Components::QueryParameters.specs[param]
      end

      response(200, "successful") do
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
        include_examples "200 successful", "#/components/schemas/ArtistsIndex"
      end

      response(401, "Unauthorized") do
        let!(:Authorization) { "Bearer INVALID TOKEN" }
        include_examples "Unauthorized"
      end

      response(403, "Forbidden") do
        before do
          stub_const("Api::V1::ArtistsController::ROLES_ACCESS", {index: %i[admin]})
        end
        let!(:Authorization) { "Bearer #{api_key_user_role.raw_token}" }
        include_examples "Forbidden"
      end

      response(429, "too many requests") do
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
        before do
          21.times do
            get "/v1/artists", headers: headers
          end
        end
        include_examples "too many requests"
      end
    end
  end
end
