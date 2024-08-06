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
Activity.destroy_all
# Subscription.destroy_all
# SubscriptionType.destroy_all
LegalGuardian.destroy_all
User.destroy_all
Staff.destroy_all

# Seed LegalGuardians
1000.times do
  LegalGuardian.create!(
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    phone: '+39 341 4488 932',
    date_of_birth: Faker::Date.birthday(min_age: 30, max_age: 60)
  )
end

puts "LegalGuardians Added"

# Seed Users with Legal Guardians
40.times do
  legal_guardian = LegalGuardian.all.sample
  User.create!(
    cf: Faker::Finance.vat_number,
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    phone: '+39 341 4488 933',
    date_of_birth: Faker::Date.birthday(min_age: 5, max_age: 17),
    med_cert_issue_date: nil,
    legal_guardian: legal_guardian,
  )
end

puts "Minor Users Added"

# Seed Users without Legal Guardians
20.times do
  User.create!(
    cf: Faker::Finance.vat_number,
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    phone: '+39 341 4488 934',
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 100),
    med_cert_issue_date: nil,
    legal_guardian: nil,
    affiliated: false
  )
end

puts "Normal Users Added"

# Seed Activities
30.times do
  ac = Activity.create!(
    name: Faker::Sport.unique.sport,
    num_participants: 30
  )

  ActivityPlan.create!(
    plan: :one_month,
    activity: ac,
    cost: 55.0
  )
end

# Seed 'sala pesi'
sala = Activity.create!(
  name: 'SALA PESI',
  num_participants: 99
)

ActivityPlan.create!(
  plan: :one_month,
  activity: sala,
  cost: 55.0
)

puts "Activities Added"

# Seed Subscription Types
# TODO
# [
#   { plan: :one, desc: 'Basic', duration: 30, cost: 29.99 },
#   { plan: :half, desc: 'Standard', duration: 60, cost: 49.99 },
#   { plan: :year, desc: 'Premium', duration: 90, cost: 79.99 }
# ].each do |subscription_type_attrs|
#   SubscriptionType.find_or_create_by!(
#     plan: subscription_type_attrs[:plan],
#     desc: subscription_type_attrs[:desc],
#     duration: subscription_type_attrs[:duration],
#     cost: subscription_type_attrs[:cost]
#   )
# end

# puts "SubscriptionTypes Added"

# users = User.all
# activities = Activity.all

# subscription_types.each do |subscription_type|
#   duration_in_days = subscription_type.duration

#   # Calcola le date di inizio e fine in base alla durata del subscription_type
#   100.times do
#     user = users.sample
#     activity = activities.sample

#     start_date = Faker::Date.backward(days: duration_in_days)  # Data di inizio è indietro di `duration_in_days` giorni
#     end_date = start_date + duration_in_days                   # Data di fine è `duration_in_days` giorni dopo la data di inizio

#     Subscription.create!(
#       start_date: start_date,
#       end_date: end_date,
#       user: user,
#       activity: activity,
#       subscription_type: subscription_type,
#       status: [0, 1, 2].sample
#     )
#   end
# end

# puts "Subscriptions Added"
# puts "Updated Users with activities"

# Seed Staff Members
admin_user = User.create!(
  cf: Faker::Finance.vat_number,
  name: 'Admin',
  surname: 'User',
  email: 'admin@example.com',
  phone: '+39 341 4488 935',
  date_of_birth: Faker::Date.birthday(min_age: 30, max_age: 60),
  med_cert_issue_date: nil,
  affiliated: false
)

puts "Admin User Added"

Staff.create!(
  user: admin_user,
  email: 'admin@example.com',
  password: 'adminpassword',
  role: :admin
)

normal_user = User.create!(
  cf: Faker::Finance.vat_number,
  name: 'Normal',
  surname: 'User',
  email: 'normal@example.com',
  phone: '+39 342 4488 935',
  date_of_birth: Faker::Date.birthday(min_age: 30, max_age: 60),
  med_cert_issue_date: nil,
  affiliated: false
)

puts "Normal User Added"

Staff.create!(
  user: normal_user,
  email: 'normal@example.com',
  password: 'normalpassword',
  role: :collaboratore
)

puts "Admin Staff Added"

10.times do
  user = User.create!(
    cf: Faker::Finance.vat_number,
    name: Faker::Name.first_name,
    surname: Faker::Name.last_name,
    email: Faker::Internet.unique.email,
    phone: '+39 341 4488 936',
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 60),
    med_cert_issue_date: nil,
    affiliated: false
  )

  Staff.create!(
    user: user,
    email: Faker::Internet.unique.email,
    password: 'password',
    role: [0, 1].sample
  )
end

puts "Staff Added"

# staff = Staff.all
# subscriptions = Subscription.all
# Payment.destroy_all

# 100.times do
#   Payment.create!(
#     amount: Faker::Commerce.price(range: 10..100),
#     date: Faker::Date.backward(days: 365),
#     method: [0, 1, 2, 3].sample,
#     payment_type: [0, 1, 2].sample,
#     entry_type: [0, 1].sample,
#     payed: true,
#     note: Faker::Lorem.sentence,
#     subscription: subscriptions.sample,
#     staff: staff.sample
#   )
# end

# puts "Payments Added"

puts "Seeding completed successfully!"
