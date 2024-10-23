# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.destroy_all
Staff.destroy_all

# CSV Import

require 'csv'

# REMEMBER TO PUT RES.CSV in LIB/SEEDS
csv_file = File.read(Rails.root.join('lib/seeds/res.csv'))
csv = CSV.parse(csv_file, headers: true)

csv.each do |row|
  u = User.new

  u.cf = row['Codice Fiscale'].length == 16 ? row['Codice Fiscale'] : nil
  u.surname = row['Cognome']
  u.name = row['Nome']
  u.birth_day = row['Data di Nascita']
  u.email = row['Email']
  u.phone = Phonelib.parse(row['Cellulare']).valid? ? row['Cellulare'] :nil

  u.save
end

# Seed Staff Members
admin_user = User.create!(
  cf: 'SRUDMN80A01L736P',
  name: 'Admin',
  surname: 'User',
  email: 'admin@example.com',
  phone: '+39 341 4488 935',
  birth_day: Faker::Date.birthday(min_age: 30, max_age: 60),
  med_cert_issue_date: nil,
  affiliated: false
)

Staff.create!(
  user: admin_user,
  nickname: 'admin',
  password: Rails.application.credentials.admin_pwd,
  role: :admin
)
