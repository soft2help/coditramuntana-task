FactoryBot.define do
  factory :artist, class: "Artist" do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
  end
end
