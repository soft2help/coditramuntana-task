FactoryBot.define do
  factory :api_key, class: "ApiKey" do
    bearer { create(:user) }
  end
end
