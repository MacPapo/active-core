FactoryBot.define do
  factory :subscription do
    start_date { Faker::Date.backward(days: 10) }
  end
end
