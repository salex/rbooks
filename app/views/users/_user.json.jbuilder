json.extract! user, :id, :email, :username, :full_name, :roles, :default_book, :created_at, :updated_at
json.url user_url(user, format: :json)
