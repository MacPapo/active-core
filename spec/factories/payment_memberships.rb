# frozen_string_literal: true

FactoryBot.define do
  factory :payment_membership do
    payment { nil }
    membership { nil }
    user { nil }
  end
end
