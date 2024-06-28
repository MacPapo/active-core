json.extract! subscription_type, :id, :desc, :duration, :cost, :created_at, :updated_at
json.url subscription_type_url(subscription_type, format: :json)
