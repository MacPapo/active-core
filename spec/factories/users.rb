FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone { '+39 341 5588 732' }
    date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 90) }
    med_cert_issue_date { Faker::Date.backward(days: 365) }
  end
end
