FactoryBot.define do
  factory :lp, class: "Lp" do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
  end
end
