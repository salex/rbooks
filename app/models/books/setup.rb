module Books
  class Setup < Book
    require 'csv'

    def self.clone_book_tree
      next_book = Book.maximum(:id) + 1
      next_acct = Account.maximum(:id)
      accts = Account.find(Current.book.settings["tree_ids"])
      accounts = []
      accts.each do |a|
        accounts << {
          account_type:a.account_type,
          name:a.name,
          description:a.description,
          placeholder:a.placeholder,
          id:a.id+next_acct,
          level:a.level,
          parent_id: (a.parent_id.nil? ? nil : a.parent_id + next_acct)
        }
      end
      accounts
    end

    def create_book_tree
      if self.id.present?
        file_name="commaccts"
        # a new book is sent from seed with id=1 and name = review
      else
        next_book = Book.maximum(:id) + 1
        file_name = self.root
        self.id = next_book
        self.root = nil
      end
      self.save # got book with only id
      arr = Books::Setup.parse_csv(file_name+'.csv')
      @accounts = arr[0]
      @accounts.each do |acct|
        new_acct = self.accounts.new(acct)
        new_acct.uuid =  SecureRandom.uuid
        if new_acct.account_type == "ROOT"
          self.root = new_acct.uuid
        end
        new_acct.save
      end
      fix_uuids
      self.settings = nil
      self.get_settings

      return true
    end

    def fix_uuids
      book = self
      root = book.accounts.find_by(account_type:"ROOT",parent_id:nil)
      book.root = root.uuid
      children = root.children
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
        else
          raise "A root child account has invalid account_type"
        end
      end
      this_checking = self.accounts.where(account_type:"BANK").where(Account.arel_table[:name].matches("checking%"))
      if this_checking.count == 1
        book.checking = this_checking.first.uuid
      end
      this_savings = self.accounts.where(account_type:"BANK").where(Account.arel_table[:name].matches("savings%"))
      if this_savings.count == 1
        book.savings = this_savings.first.uuid
      end
      if  book.changed?
        book.save
      end
    end


    def self.parse_csv(csv_file)
      acct_path = Rails.root.join("yaml/books/#{csv_file}")
      next_book = Book.maximum(:id) + 1
      next_account = Account.maximum(:id) + 1
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
      accounts = [{account_type:'ROOT',name:'Root Account',description:'Root Account',level:0, parent_id:nil,id:id,placeholder:true}]
      accts.each_with_index do |a,idx|
        this_level = a[full_name].split(':').count
        this_id = idx + 1 + id
        if this_level == 1
          # we have a root child
          this_type = a[type]
          this_parent_id = next_account
          parent_ids[this_level] = this_id
          accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:1, parent_id:this_parent_id,id:this_id,placeholder:true}

        elsif this_level == last_level
          # we have a sibling of the last acct that could be a parent
          this_type = a[type]
          this_parent_id = parent_ids[this_level -1]
          parent_ids[this_level] = this_id
          accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

        elsif this_level > last_level
          # we have a new branch with level > 1
          this_type = a[type]
          this_parent_id = parent_ids[last_level]
          parent_ids[this_level] = this_id
          accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

        elsif this_level < last_level
          # we have a new branch with level > 1
          this_type = a[type]
          this_parent_id = parent_ids[this_level -1]
          parent_ids[this_level] = this_id
          accounts << {account_type:this_type,name:a[name_desc],description:a[full_name],level:this_level, parent_id:this_parent_id,id:this_id,placeholder:false}

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
end

