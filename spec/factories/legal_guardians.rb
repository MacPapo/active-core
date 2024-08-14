FactoryBot.define do
  factory :legal_guardian do
    name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone { '+39 341 5588 733' }
    birth_day { Faker::Date.birthday(min_age: 18, max_age: 90) }
  end
end
