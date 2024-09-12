RSpec.shared_examples "200 successful" do |schema|
  produces "application/vnd.api+json"
  schema "$ref" => schema

  after do |example|
    example.metadata[:response][:content] = {
      "application/vnd.api+json" => {
        example: JSON.parse(response.body, symbolize_names: true)
      }
    }
  end

  run_test!
end

RSpec.shared_examples "NotFound" do
  produces "application/json"
  schema "$ref" => "#/components/schemas/Errors"
  run_test!
end

RSpec.shared_examples "Unauthorized" do
  produces "application/json"
  schema "$ref" => "#/components/schemas/Error"
  run_test!
end

RSpec.shared_examples "Forbidden" do
  produces "application/json"
  schema "$ref" => "#/components/schemas/Errors"

  it "returns a 403 status code" do
    expect(response).to have_http_status(403)
    expect(json["errors"].any? { |item| item["code"] == "USER-DONT-HAVE-ROLES-TO-ACTION" }).to be_truthy
  end
  run_test!
end

RSpec.shared_examples "too many requests" do
  produces "application/json"
  schema "$ref" => "#/components/schemas/Errors"
  header "ratelimit-limit", schema: {type: :integer}, description: "The number of allowed requests in the current period"
  header "ratelimit-remaining", schema: {type: :integer}, description: "The number of remaining requests in the current period"
  header "ratelimit-reset", schema: {type: :integer}, description: "Timestamp that the current period will reset"

  it "returns a 429 status code" do
    expect(response).to have_http_status(429)
  end
  run_test!
end
