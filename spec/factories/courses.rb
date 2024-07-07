FactoryBot.define do
  factory :course do
    name { Faker::Sport.unique.sport }
  end
end
