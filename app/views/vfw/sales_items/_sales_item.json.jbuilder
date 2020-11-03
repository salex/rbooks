json.extract! sales_item, :id, :name, :type, :price, :cost, :department, :markup, :quanity, :alert, :size, :cases, :bottles, :bottles_1, :bottles_2, :percent, :created_at, :updated_at
json.url sales_item_url(sales_item, format: :json)
