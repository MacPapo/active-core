# frozen_string_literal: true

FactoryBot.define do
  factory :receipt do
    payment { nil }
    user { nil }
    amount { 1.5 }
    cause { 'MyString' }
    date { '2024-08-26' }
  end
end
