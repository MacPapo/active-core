# frozen_string_literal: true

FactoryBot.define do
  factory :staff do
    nickname { Faker::Internet.username(specifier: 5..10) }
    password { 'password' }
  end
end
