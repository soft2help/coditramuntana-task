require "swagger_helper"

RSpec.describe "/v1/artists", type: :request, openapi_spec: "v1/swagger.yaml" do
  include_context "with clean redis"
  include_context "authentication setup"

  describe "list available artists" do
    let(:artist_payload) do
      {
        data: {
          attributes: {
            name: "Metallica"
          }
        }
      }.to_json
    end

    let(:invalid_artist_payload_lower) do
      {
        data: {
          attributes: {
            name: "a"
          }
        }
      }.to_json
    end

    let(:invalid_artist_payload_bigger) do
      {
        data: {
          attributes: {
            name: "a" * 51
          }
        }
      }.to_json
    end
    context "check authentication actions" do
      it "[NOT AUTHENTICATED]" do
        post "/v1/artists"
        expect(response.status).to eq(401)
      end

      it "[AUTHENTICATED] USER WITHOUT EXPECTED ROLE " do
        post "/v1/artists", headers: {Authorization: "Bearer #{api_key_user_basic.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].first["code"]).to eq("USER-DONT-HAVE-ROLES-TO-ACTION")
      end

      it "[AUTHENTICATED] access control rules [Header Value Check]" do
        post "/v1/artists", headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "HEADER-VALUE-NOT-VALID" }).to be_truthy
      end

      it "[AUTHENTICATED] access control rules VALID [Header Value Check]" do
        post "/v1/artists", params: artist_payload, headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}", "X-Custom-Header": "Test", "Content-Type": "application/json"}
        expect(response.status).to eq(200)
      end

      it "[AUTHENTICATED] ip control rules [INVALID IP ACCESS]" do
        post "/v1/artists", headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "1.1.1.1"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "IP-ADDRESS-NOT-ALLOWED" }).to be_truthy
      end

      it "[AUTHENTICATED] ip control rules [VALID IP ACCESS]" do
        post "/v1/artists", params: artist_payload, headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "172.25.94.167", :"Content-Type" => "application/json"}
        expect(response.status).to eq(200)
      end

      it "[VALIDATION] Persist Artist [VALID DATA]" do
        post "/v1/artists", params: artist_payload, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(200)
      end

      it "[VALIDATION] Duplicated" do
        Artist.create({name: "Metallica"})
        post "/v1/artists", params: artist_payload, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(400)
        expect(json["errors"].any? { |item| item["message"] == "Name has already been taken" }).to be_truthy
      end

      it "[VALIDATION] Name smaller than allowed" do
        post "/v1/artists", params: invalid_artist_payload_lower, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(400)
        expect(json["errors"].any? { |item| item["message"] == "Name is too short (minimum is 3 characters)" }).to be_truthy
      end

      it "[VALIDATION] Name bigger than allowed" do
        post "/v1/artists", params: invalid_artist_payload_bigger, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(400)
        expect(json["errors"].any? { |item| item["message"] == "Name is too long (maximum is 50 characters)" }).to be_truthy
      end
    end
  end

  path "/v1/artists" do
    post("Add new Artist") do
      description "Add new Artist"
      operationId "addArtist"
      tags "USER"
      security [BearerAuth: []]
      consumes "application/json"
      produces "application/json"

      let(:artist) { {data: {attributes: {name: "Sepultura"}}} }

      Api::V1::Components::Artists::CreateParameters.specs.each do |param, spec|
        parameter spec
      end

      response(200, "successful") do
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }

        include_examples "200 successful", "#/components/schemas/ArtistsShow"
      end

      response(401, "Unauthorized") do
        let!(:Authorization) { "Bearer INVALID TOKEN" }
        include_examples "Unauthorized"
      end

      response(403, "Forbidden") do
        before do
          stub_const("Api::V1::ArtistsController::ROLES_ACCESS", {create: %i[admin]})
        end
        let!(:Authorization) { "Bearer #{api_key_user_role.raw_token}" }
        include_examples "Forbidden"
      end

      response(429, "too many requests") do
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
        let(:artist_payload) { {data: {attributes: {name: "Sepultura"}}} }
        before do
          21.times do
            post "/v1/artists", params: artist_payload, headers: headers
          end
        end
        include_examples "too many requests"
      end
    end
  end
end
