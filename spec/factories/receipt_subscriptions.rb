# frozen_string_literal: true

FactoryBot.define do
  factory :receipt_subscription do
    receipt { nil }
    subscription { nil }
    user { nil }
    number { 1 }
    year { 1 }
  end
end
