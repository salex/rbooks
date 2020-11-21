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

  class BizzAccts
    require 'csv'
    def parse(next_book, next_account)
      acct_path = Rails.root.join('yaml/bizz.csv')
      accts = CSV.parse(File.read(acct_path))
      keys = accts.delete_at(0)
      type = 0
      full_name = 1
      name_desc = 2
      placeholder = 11
      id = next_account
      book_id = next_book
      last_level = 0
      this_type = ''
      parent_id = next_account
      parent_ids = [nil,next_account]
      accounts = [{type:'ROOT',name:'Root Account',level:0, parent_id:nil,id:id,placeholder:true}]
      accts.each_with_index do |a,idx|
        this_level = a[full_name].split(':').count
        this_id = idx + 1 + id
        if this_level == 1
          # we have a root child
          this_type = a[type]
          this_parent_id = next_account
          parent_ids[this_level] = this_id
          accounts << {type:this_type,name:a[name_desc],level:1, parent_id:this_parent_id,id:this_id,placeholder:true}

        elsif this_level == last_level
          # we have a sibling of the last acct that could be a parent
          this_type = a[type]
          this_parent_id = parent_ids[this_level -1]
          parent_ids[this_level] = this_id
          accounts << {type:this_type,name:a[name_desc],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

        elsif this_level > last_level
          # we have a new branch with level > 1
          this_type = a[type]
          this_parent_id = parent_ids[last_level]
          parent_ids[this_level] = this_id
          accounts << {type:this_type,name:a[name_desc],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

        elsif this_level < last_level
          # we have a new branch with level > 1
          this_type = a[type]
          this_parent_id = parent_ids[this_level -1]
          parent_ids[this_level] = this_id
          accounts << {type:this_type,name:a[name_desc],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

        end
        last_level = this_level
      end
      # accounts
      trees = {next_account => []}
      accounts.each do |a|
        if trees.has_key?(a[:parent_id])
          trees[a[:parent_id]] << a[:id]
        else
          trees[a[:parent_id]] = [a[:id]]
        end
      end
      trees.delete(nil)
      return [accounts,trees]
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
      fixtures[:book] = bfixtures
      fixtures[:account] = afixtures
      # fixtures[:entry] = efixtures
      # fixtures[:split] = sfixtures
      fixtures
    end
  end

end
