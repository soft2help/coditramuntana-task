FactoryBot.define do
  factory :author, class: "Author" do
    name { Faker::Name.name }
  end
end
