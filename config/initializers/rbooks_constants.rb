ACCT_TYPES =  %w{ASSET BANK CASH CREDIT EQUITY EXPENSE INCOME LIABILITY PAYABLE RECEIVABLE ROOT}.freeze

ROOT_ACCOUNTS = %w{ROOT ASSET LIABILITY EQUITY INCOME EXPENSE}

RBooks::Application.config.x.acct_updated = Time.now.utc.to_s

Rack::MiniProfiler.config.position = 'right'



