# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# User.destroy_all
# Staff.destroy_all

# # CSV Import

# require 'csv'

# # REMEMBER TO PUT RES.CSV in LIB/SEEDS
# csv_file = File.read(Rails.root.join('lib/seeds/res.csv'))
# csv = CSV.parse(csv_file, headers: true)

# csv.each do |row|
#   u = User.new

#   u.tax_code = row['Codice Fiscale'].length == 16 ? row['Codice Fiscale'] : nil
#   u.last_name = row['Cognome']
#   u.name = row['Nome']
#   u.birth_date = row['Data di Nascita']
#   u.email = row['Email']
#   u.phone = Phonelib.parse(row['Cellulare']).valid? ? row['Cellulare'] : nil

#   u.save
# end

# Seed Staff Members
admin_user = Member.new(
  tax_code: 'SRUDMN80A01L736P',
  name: 'Admin',
  last_name: 'User',
  email: 'admin@example.com',
  phone: '+39 341 4488 935',
  birth_date: Date.new(2001, 3, 18),
  medical_certificate_issued_on: nil,
  affiliated: false
)

admin_user.save

staff_admin = User.new(
  member: admin_user,
  nickname: 'admin',
  password: 'admin',
  role: :admin
)

staff_admin.save
