json.extract! book, :id, :name, :root, :assets, :equity, :liabilities, :income, :expenses, :checking, :savings, :settings, :created_at, :updated_at
json.url book_url(book, format: :json)
