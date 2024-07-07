FactoryBot.define do
  factory :staff do
    email { Faker::Internet.email }
    password { 'password' }
    role { [0, 1, 2].sample }
  end
end
