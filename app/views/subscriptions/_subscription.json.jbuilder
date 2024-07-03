json.extract! subscription, :id, :start, :end, :user_id, :course_id, :subscription_type_id, :state, :created_at, :updated_at
json.url subscription_url(subscription, format: :json)
