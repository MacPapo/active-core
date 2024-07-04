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
Course.destroy_all
Subscription.destroy_all
SubscriptionType.destroy_all
LegalGuardian.destroy_all
User.destroy_all
Staff.destroy_all

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

puts "LegalGuardians Added"

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

puts "Minor Users Added"

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

puts "Normal Users Added"

# Seed Courses
30.times do
  Course.create!(
    name: Faker::Sport.unique.sport
  )
end

puts "Courses Added"

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

puts "SubscriptionTypes Added"

users = User.all
courses = Course.all
subscription_types = SubscriptionType.all

subscription_types.each do |subscription_type|
  duration_in_days = subscription_type.duration

  # Calcola le date di inizio e fine in base alla durata del subscription_type
  100.times do
    user = users.sample
    course = courses.sample

    start_date = Faker::Date.backward(days: duration_in_days)  # Data di inizio è indietro di `duration_in_days` giorni
    end_date = start_date + duration_in_days                   # Data di fine è `duration_in_days` giorni dopo la data di inizio

    Subscription.create!(
      start: start_date,
      end: end_date,
      user: user,
      course: course,
      subscription_type: subscription_type,
      state: ['attivo', 'scaduto', 'cancellato'].sample
    )
  end
end

puts "Subscriptions Added"
puts "Updated Users with courses"

# Seed Staff Members
admin_user = User.create!(
  name: 'Admin',
  surname: 'User',
  email: 'admin@example.com',
  phone: Faker::PhoneNumber.cell_phone_in_e164,
  date_of_birth: Faker::Date.birthday(min_age: 30, max_age: 60),
  med_cert_exp_date: nil
)

puts "Admin User Added"

Staff.create!(
  user: admin_user,
  card_expiry_date: nil,
  password: 'adminpassword',
  role: 'admin'
)

puts "Admin Staff Added"

10.times do
  user = User.create!(
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.email,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 60),
    med_cert_exp_date: nil
  )

  Staff.create!(
    user: user,
    card_expiry_date: Faker::Date.forward(days: 365),
    password: 'password',
    role: ['collaboratore', 'volontario'].sample
  )
end

puts "Staff Added"

staff = Staff.all
subscriptions = Subscription.all

100.times do
  Payment.create!(
    amount: Faker::Commerce.price(range: 10..100),
    date: Faker::Date.backward(days: 365),
    method: ['pos', 'contanti', 'bonifico'].sample,
    payment_type: ['abbonamento', 'quota', 'altro'].sample,
    entry_type: ['uscita', 'entrata'].sample,
    state: ['pagato', 'non_pagato'].sample,
    note: Faker::Lorem.sentence,
    subscription: subscriptions.sample,
    staff: staff.sample
  )
end

puts "Payments Added"

puts "Seeding completed successfully!"
