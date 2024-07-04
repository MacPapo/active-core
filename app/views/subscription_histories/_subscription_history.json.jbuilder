json.extract! subscription_history, :id, :renewal_date, :old_end_date, :new_end_date, :action, :subscription_id, :staff_id, :created_at, :updated_at
json.url subscription_history_url(subscription_history, format: :json)
