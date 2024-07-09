json.extract! activity, :id, :name, :created_at, :updated_at
json.url course_url(activity, format: :json)
