json.extract! payment, :id, :amount, :date, :method, :income, :note, :staff_id, :created_at, :updated_at
json.url payment_url(payment, format: :json)
