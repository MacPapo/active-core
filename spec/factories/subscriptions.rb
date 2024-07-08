FactoryBot.define do
  factory :subscription do
    start_date { Faker::Date.backward(days: 10) }
    end_date { Faker::Date.forward(days: 10) }
    state { [0, 1].sample }
  end
end
