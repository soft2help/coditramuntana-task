RSpec.shared_context "authentication setup", shared_context: :metadata do
  let!(:user) { create(:user, email: "teste@teste.com") }
  let!(:api_key) { create(:api_key, bearer: user) }

  let!(:user_user) { create(:user, roles: [:user], email: "user@user.com") }
  let!(:api_key_user_role) { create(:api_key, bearer: user_user) }

  let!(:user_basic) { create(:user, roles: [:basic], email: "userbasic@userbasic.com") }
  let!(:api_key_user_basic) { create(:api_key, bearer: user_basic) }

  let!(:user_admin) { create(:user, roles: [:admin], email: "admin@user.com") }
  let!(:api_key_admin_role) { create(:api_key, bearer: user_admin) }

  let!(:realm) { Setting.set("api", "realm", "Public Api Token") }

  let!(:headers) do
    {
      Authorization: "Bearer #{api_key.raw_token}"
    }
  end
  let!(:api_key_normal_access) {
    create(:api_key, bearer: user)
  }

  let!(:api_key_access_rules_header_value) {
    create(:api_key, bearer: user, access_control_rules: {
      header: [
        name: "X-Custom-Header", value: "Test"
      ]
    })
  }

  let!(:api_key_access_rules_ip) {
    create(:api_key, bearer: user, access_control_rules: {
      ip: [
        {type: "ip", value: "172.25.94.167"}
      ]
    })
  }
end
