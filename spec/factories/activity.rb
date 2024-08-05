FactoryBot.define do
  factory :activity do
    name { Faker::Sport.unique.sport }
    num_participants { 20 }
  end
end
