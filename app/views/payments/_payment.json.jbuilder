json.extract! payment, :id, :amount, :date, :method, :payment_type, :entry_type, :state, :note, :subscription_id, :staff_id, :created_at, :updated_at
json.url payment_url(payment, format: :json)
