json.extract! legal_guardian, :id, :name, :surname, :email, :phone, :date_of_birth, :created_at, :updated_at
json.url legal_guardian_url(legal_guardian, format: :json)
