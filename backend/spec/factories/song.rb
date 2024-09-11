FactoryBot.define do
  factory :song, class: "Song" do
    title { Faker::Name.name }
  end
end
