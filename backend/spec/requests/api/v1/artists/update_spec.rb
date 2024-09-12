require "swagger_helper"

RSpec.describe "/v1/artists", type: :request, openapi_spec: "v1/swagger.yaml" do
  include_context "with clean redis"
  include_context "authentication setup"

  describe "list available artists" do
    let!(:artist) { create(:artist) }

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
        put "/v1/artists/#{artist.id}"
        expect(response.status).to eq(401)
      end

      it "[AUTHENTICATED] USER WITHOUT EXPECTED ROLE " do
        put "/v1/artists/#{artist.id}", headers: {Authorization: "Bearer #{api_key_user_basic.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].first["code"]).to eq("USER-DONT-HAVE-ROLES-TO-ACTION")
      end

      it "[AUTHENTICATED] access control rules [Header Value Check]" do
        put "/v1/artists/#{artist.id}", headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "HEADER-VALUE-NOT-VALID" }).to be_truthy
      end

      it "[AUTHENTICATED] access control rules VALID [Header Value Check]" do
        put "/v1/artists/#{artist.id}", params: artist_payload, headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}", "X-Custom-Header": "Test", "Content-Type": "application/json"}
        expect(response.status).to eq(200)
      end

      it "[AUTHENTICATED] ip control rules [INVALID IP ACCESS]" do
        put "/v1/artists/#{artist.id}", headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "1.1.1.1"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "IP-ADDRESS-NOT-ALLOWED" }).to be_truthy
      end

      it "[AUTHENTICATED] ip control rules [VALID IP ACCESS]" do
        put "/v1/artists/#{artist.id}", params: artist_payload, headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "172.25.94.167", :"Content-Type" => "application/json"}
        expect(response.status).to eq(200)
      end

      it "[VALIDATION] Persist Artist [VALID DATA]" do
        put "/v1/artists/#{artist.id}", params: artist_payload, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(200)
      end

      it "[VALIDATION] Duplicated" do
        Artist.create({name: "Metallica"})
        put "/v1/artists/#{artist.id}", params: artist_payload, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(400)
        expect(json["errors"].any? { |item| item["message"] == "Name has already been taken" }).to be_truthy
      end

      it "[VALIDATION] Name smaller than allowed" do
        put "/v1/artists/#{artist.id}", params: invalid_artist_payload_lower, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(400)
        expect(json["errors"].any? { |item| item["message"] == "Name is too short (minimum is 3 characters)" }).to be_truthy
      end

      it "[VALIDATION] Name bigger than allowed" do
        put "/v1/artists/#{artist.id}", params: invalid_artist_payload_bigger, headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(400)
        expect(json["errors"].any? { |item| item["message"] == "Name is too long (maximum is 50 characters)" }).to be_truthy
      end
    end
  end

  path "/v1/artists/{id}" do
    put("update Artist") do
      description "Update Artist"
      operationId "updateArtist"
      tags "USER"
      security [BearerAuth: []]
      consumes "application/json"
      produces "application/json"

      let(:artist) { {data: {attributes: {name: "Sepultura"}}} }
      parameter name: :id, in: :path, type: :string, description: "Artist ID"
      Api::V1::Components::Artists::CreateParameters.specs.each do |param, spec|
        parameter spec
      end

      response(200, "successful") do
        let(:existing_artist) { create(:artist, name: "Old Name") }
        let(:id) { existing_artist.id }
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
        let(:artist) { {data: {attributes: {name: "Sepultura"}}} }
        include_examples "200 successful", "#/components/schemas/ArtistsShow"
      end

      response(404, "Not Found") do
        let(:existing_artist) { create(:artist, name: "Old Name") }
        let(:id) { 100 }
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
        let(:artist) { {data: {attributes: {name: "Sepultura"}}} }
        include_examples "NotFound"
      end

      response(401, "Unauthorized") do
        let(:existing_artist) { create(:artist, name: "Old Name") }
        let(:id) { existing_artist.id }
        let!(:Authorization) { "Bearer INVALID TOKEN" }
        include_examples "Unauthorized"
      end

      response(403, "Forbidden") do
        before do
          stub_const("Api::V1::ArtistsController::ROLES_ACCESS", {update: %i[admin]})
        end
        let(:existing_artist) { create(:artist, name: "Old Name") }
        let(:id) { existing_artist.id }
        let!(:Authorization) { "Bearer #{api_key_user_role.raw_token}" }
        include_examples "Forbidden"
      end

      response(429, "too many requests") do
        let(:existing_artist) { create(:artist, name: "Old Name") }
        let(:id) { existing_artist.id }
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
        let(:artist_payload) { {data: {attributes: {name: "Sepultura"}}} }
        before do
          21.times do
            put "/v1/artists/#{id}", params: artist_payload, headers: headers
          end
        end
        include_examples "too many requests"
      end
    end
  end
end
