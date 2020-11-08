module Fix
  # ROOT_ACCOUNTS = %w{ROOT ASSET LIABILITY EQUITY INCOME EXPENSE}
  # fixes are usually one time method to fix some import process that failed

  class Revenue < ApplicationRecord
    self.inheritance_column = nil
  end

  class SalesItem < ApplicationRecord
    self.inheritance_column = nil
  end

  class Fixes

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
      Fix::Revenue.all.each do |r|
        r.type = "Vfw::"+r.type
        r.save
      end
    end

    def fix_sales_items_type
      Fix::SalesItem.all.each do |r|
        if !r.type.include?('Vfw::')
          r.type = "Vfw::"+r.type
          r.save
        end
        end
    end

  end

  class Fixtures
    def self.to_fixture
      fixtures = {}
      book = Book.order(:id).select(:id,:name,:root,:assets,:equity,:liabilities,:income,:expenses,:checking,:savings,:settings )
      bfixtures = {}
      book.each do |a|
        key = ('b'+a.id.to_s)
        bfixtures[key] = {id:a.id,
          name:a.name,
          root:a.root,
          assets:a.assets,
          equity:a.equity,
          liabilities:a.liabilities,
          income:a.income,
          expenses:a.expenses,
          checking:a.checking,
          savings:a.savings,
          settings:{}.with_indifferent_access
          }
      end
      
      acct = Account.order(:id).select(:id,:uuid,:book_id,:name,:account_type,:description,:parent_id,:placeholder,:level)
      afixtures = {}
      acct.each do |a|
        key = ('a'+a.id.to_s)
        parent = "<%= ActiveRecord::FixtureSet.identify(#{(':a'+a.parent_id.to_s)}) %>"
        afixtures[key] = {id:a.id,uuid:a.uuid,book:'b1',parent_id:parent,name:a.name,account_type:a.account_type,
          placeholder:a.placeholder,level:a.level}
      end
      # entries = Entry.order(:post_date).reverse_order.select(:id, :numb, :post_date, :description, :fit_id).limit(10)
      # efixtures = {}
      # sfixtures = {}

      # entries.each do |e|
      #   key = ('e'+e.id.to_s)
      #   efixtures[key] = {id:e.id,numb:e.numb,post_date: e.post_date,description:e.description,fit_id: e.fit_id}
      #   e.splits.each do |s|
      #     key = ('s'+s.id.to_s)
      #     sacct = ('a'+s.account_id.to_s)
      #     sentry = ('e'+s.entry_id.to_s)
      #     sfixtures[key] = {id:s.id,entry:sentry,account:sacct,memo:s.memo,action:s.action,
      #       reconcile_state:s.reconcile_state,reconcile_date:s.reconcile_date,amount:s.amount}
      #   end
      # end
      fixtures[:book] = bfixtures
      fixtures[:account] = afixtures
      # fixtures[:entry] = efixtures
      # fixtures[:split] = sfixtures
      fixtures
    end
  end

end
