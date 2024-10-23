# frozen_string_literal: true

FactoryBot.define do
  factory :receipt do
    payment { nil }
    amount { '9.99' }
    date { '2024-10-09' }
    staff { nil }
  end
end
