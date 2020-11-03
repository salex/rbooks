json.extract! account, :id, :uuid, :book_id, :name, :account_type, :code, :description, :placeholder, :contra, :parent_id, :level, :created_at, :updated_at
json.url account_url(account, format: :json)
