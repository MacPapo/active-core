# frozen_string_literal: true

FactoryBot.define do
  factory :receipt_membership do
    receipt { nil }
    membership { nil }
    user { nil }
    number { 1 }
    year { 1 }
  end
end
