# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    amount { '9.99' }
    date { '2024-10-09' }
    type { 1 }
    income { false }
    note { 'MyText' }
    staff { nil }
  end
end
