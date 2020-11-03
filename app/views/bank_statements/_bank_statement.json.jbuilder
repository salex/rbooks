json.extract! bank_statement, :id, :book_id, :statement_date, :beginning_balance, :ending_balance, :ofx_data, :hash_data, :reconciled_date, :created_at, :updated_at
json.url bank_statement_url(bank_statement, format: :json)
