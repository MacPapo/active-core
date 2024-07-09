FactoryBot.define do
  factory :activity do
    name { Faker::Sport.unique.sport }
  end
end
