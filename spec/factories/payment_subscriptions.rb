# frozen_string_literal: true

FactoryBot.define do
  factory :payment_subscription do
    payment { nil }
    subscription { nil }
    user { nil }
  end
end
