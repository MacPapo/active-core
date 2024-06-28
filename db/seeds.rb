# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clean up existing data to ensure idempotency
User.destroy_all
LegalGuardian.destroy_all
Course.destroy_all
SubscriptionType.destroy_all

# Seed LegalGuardians
10.times do
  LegalGuardian.create!(
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    date_of_birth: Faker::Date.birthday(min_age: 30, max_age: 60)
  )
end

# Seed Users with Legal Guardians
40.times do
  legal_guardian = LegalGuardian.all.sample
  User.create!(
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    date_of_birth: Faker::Date.birthday(min_age: 5, max_age: 17),
    med_cert_exp_date: Faker::Date.forward(days: 365),
    legal_guardian: legal_guardian
  )
end

# Seed Users without Legal Guardians
20.times do
  User.create!(
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 100),
    med_cert_exp_date: Faker::Date.forward(days: 365),
    legal_guardian: nil
  )
end

# Seed Courses
30.times do
  Course.create!(
    name: Faker::Sport.sport
  )
end

# Seed Subscription Types
[
  { desc: 'Basic', duration: 30, cost: 29.99 },
  { desc: 'Standard', duration: 60, cost: 49.99 },
  { desc: 'Premium', duration: 90, cost: 79.99 }
].each do |subscription_type_attrs|
  SubscriptionType.find_or_create_by!(
    desc: subscription_type_attrs[:desc],
    duration: subscription_type_attrs[:duration],
    cost: subscription_type_attrs[:cost]
  )
end

puts "Seeding completed successfully!"
