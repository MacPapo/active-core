FactoryBot.define do
  factory :activity_plan do
    plan { :one_month }
    cost { 55 }
    affiliated_cost { 45 }
  end
end
