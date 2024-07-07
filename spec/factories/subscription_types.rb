FactoryBot.define do
  factory :subscription_type do
    plan { [:half, :one, :three, :year].sample }
    desc { ['1/2 mese', '1 mese', '3 mesi', '1 anno'].sample }
    duration { [15, 30, 90, 360].sample }
    cost { [40, 60, 150, 1000].sample }
  end
end
