FactoryBot.define do
  factory :membership do
    date { "2024-07-09" }
    active { false }
    subscription_type { nil }
    user { nil }
  end
end
