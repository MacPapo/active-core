FactoryBot.define do
  factory :legal_guardian do
    name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.cell_phone_in_e164 }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 90) }
  end
end
