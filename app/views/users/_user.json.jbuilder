json.extract! user, :id, :name, :surname, :email, :phone, :date_of_birth, :med_cert_exp_date, :legal_guardian_id, :created_at, :updated_at
json.url user_url(user, format: :json)
