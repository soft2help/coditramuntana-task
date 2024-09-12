require "swagger_helper"

RSpec.describe "/v1/artists", type: :request, openapi_spec: "v1/swagger.yaml" do
  include_context "with clean redis"
  include_context "authentication setup"

  describe "Show Artist" do
    let!(:artist) { create(:artist) }

    context "check authentication actions" do
      it "[NOT AUTHENTICATED]" do
        get "/v1/artists/#{artist.id}"
        expect(response.status).to eq(401)
      end

      it "[AUTHENTICATED] USER WITHOUT EXPECTED ROLE " do
        get "/v1/artists/#{artist.id}", headers: {Authorization: "Bearer #{api_key_user_basic.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].first["code"]).to eq("USER-DONT-HAVE-ROLES-TO-ACTION")
      end

      it "[AUTHENTICATED] access control rules [Header Value Check]" do
        get "/v1/artists/#{artist.id}", headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "HEADER-VALUE-NOT-VALID" }).to be_truthy
      end

      it "[AUTHENTICATED] access control rules VALID [Header Value Check]" do
        get "/v1/artists/#{artist.id}", headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}", "X-Custom-Header": "Test", "Content-Type": "application/json"}
        expect(response.status).to eq(200)
      end

      it "[AUTHENTICATED] ip control rules [INVALID IP ACCESS]" do
        get "/v1/artists/#{artist.id}", headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "1.1.1.1"}
        expect(response.status).to eq(403)
        expect(json["errors"].any? { |item| item["code"] == "IP-ADDRESS-NOT-ALLOWED" }).to be_truthy
      end

      it "[AUTHENTICATED] ip control rules [VALID IP ACCESS]" do
        get "/v1/artists/#{artist.id}", headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "172.25.94.167", :"Content-Type" => "application/json"}
        expect(response.status).to eq(200)
      end

      it "Get Artist" do
        get "/v1/artists/#{artist.id}", headers: {Authorization: "Bearer #{api_key_user_role.raw_token}", "Content-Type": "application/json"}
        expect(response.status).to eq(200)
      end
    end
  end

  path "/v1/artists/{id}" do
    get("show Artist") do
      description "Show Artist"
      operationId "showArtist"
      tags "USER"
      security [BearerAuth: []]
      consumes "application/json"
      produces "application/json"

      let(:artist) { {data: {attributes: {name: "Sepultura"}}} }
      parameter name: :id, in: :path, type: :string, description: "Artist ID"

      response(200, "successful") do
        let(:existing_artist) { create(:artist, name: "Old Name") }
        let(:id) { existing_artist.id }
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
        include_examples "200 successful", "#/components/schemas/ArtistsShow"
      end

      response(404, "Not Found") do
        let(:existing_artist) { create(:artist, name: "Old Name") }
        let(:id) { 100 }
        let!(:Authorization) { "Bearer #{api_key.raw_token}" }
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
          stub_const("Api::V1::ArtistsController::ROLES_ACCESS", {show: %i[admin]})
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
            get "/v1/artists/#{id}", headers: headers
          end
        end
        include_examples "too many requests"
      end
    end
  end
end
