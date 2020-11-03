class Fixes
# fixes are usually one time method to fix some import process that failed
ROOT_ACCOUNTS = %w{ROOT ASSET LIABILITY EQUITY INCOME EXPENSE}

  def fix_uuids(book_id)
    book = Book.find book_id
    root = book.accounts.find_by(account_type:"ROOT",parent_id:nil)
    book.root = root.uuid
    children = Account.where(parent_id:root.id)
    children.each do |acct|
      case acct['account_type']
      when 'ASSET'
        book.assets = acct.uuid
      when 'INCOME'
        book.income = acct['uuid']
      when 'LIABILITY'
        book.liabilities = acct['uuid']
      when 'EXPENSE'
        book.expenses = acct['uuid']
      when 'EQUITY'
        book.equity = acct['uuid']
      when 'BANK'
        acct['uuid'] = SecureRandom.uuid
      else
        raise "A root child account has invalid account_type"
      end
    end
    if  book.changed?
      book.save
    end
  end

  def fix_revenue_type
    Revenue.all.each do |r|
      r.type = "Vfw::"+r.type
      r.save
    end
  end

  def fix_sales_items_type
    Vfw::SalesItem.all.each do |r|
      r.type = "Vfw::"+r.type
      r.save
    end
  end



end
