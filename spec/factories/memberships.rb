FactoryBot.define do
  factory :membership do
    date { "2024-07-09" }
    active { false }
    user { nil }
  end
end
