RSpec.shared_examples "access control tests" do |endpoint|
  it "[NOT AUTHENTICATED]" do
    get endpoint
    expect(response.status).to eq(401)
  end

  it "[AUTHENTICATED] USER WITHOUT EXPECTED ROLE" do
    get endpoint, headers: {Authorization: "Bearer #{api_key_user_basic.raw_token}"}
    expect(response.status).to eq(403)
    expect(json["errors"].first["code"]).to eq("USER-DONT-HAVE-ROLES-TO-ACTION")
  end

  it "[AUTHENTICATED] access control rules [Header Value Check]" do
    get endpoint, headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}"}
    expect(response.status).to eq(403)
    expect(json["errors"].any? { |item| item["code"] == "HEADER-VALUE-NOT-VALID" }).to be_truthy
  end

  it "[AUTHENTICATED] access control rules VALID [Header Value Check]" do
    get endpoint, headers: {Authorization: "Bearer #{api_key_access_rules_header_value.raw_token}", "X-Custom-Header": "Test"}
    expect(response.status).to eq(200)
  end

  it "[AUTHENTICATED] ip control rules [INVALID IP ACCESS]" do
    get endpoint, headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "1.1.1.1"}
    expect(response.status).to eq(403)
    expect(json["errors"].any? { |item| item["code"] == "IP-ADDRESS-NOT-ALLOWED" }).to be_truthy
  end

  it "[AUTHENTICATED] ip control rules [VALID IP ACCESS]" do
    get endpoint, headers: {:Authorization => "Bearer #{api_key_access_rules_ip.raw_token}", "REMOTE_ADDR" => "172.25.94.167"}
    expect(response.status).to eq(200)
  end
end
