FactoryBot.define do
  factory :user, class: "User" do
    email { Faker::Internet.email }
    password { "Super2024**" }
    roles { [:super_admin] }
  end
end
