class ImportYaml
  attr_accessor :book, :book_name, :accounts_array, :yaml_path, :ok

  def initialize(book_name,save=false)
    @save = save
    @book_name = book_name
    @yaml_path = Rails.root.join('../../Common/dumps')
  end

  def import_accounts
    filepath = yaml_path + 'accounts.yaml'
    @accounts_array = YAML.load_file(filepath)
    new_book
    root_id = Account.maximum(:id) + 1
    last_id = root_id

    accounts_array.each do |acct|
      acct.delete('created_at')
      acct.delete('updated_at')
      acct['book_id'] = @book_id
      acct["id"] = last_id
      unless acct["parent_id"].blank?
        acct["parent_id"]  +=  (root_id -1)
      end
      last_id += 1
      acct['book_id'] = book.id
      if acct['account_type'] == 'ROOT' && acct['name'] != "Template Root"
        acct['uuid'] = book.root
      elsif acct['parent_id'] == 1
        case acct['account_type']
        when 'ROOT'
          acct['uuid'] = book.root
        when 'ASSET'
          acct['uuid'] = book.assets
        when 'INCOME'
          acct['uuid'] = book.income
        when 'LIABILITY'
          acct['uuid'] = book.liabilities
        when 'EXPENSE'
          acct['uuid'] = book.expenses
        when 'EQUITY'
          acct['uuid'] = book.equity
        when 'BANK'
          acct['uuid'] = SecureRandom.uuid
        else
          raise "A root child account has invalid account_type"
        end
      else
        # special accounts defined in book or default
        case acct['name']
        when 'Checking'
          acct['uuid'] = book.checking
        when 'Savings'
          acct['uuid'] = book.savings
        else
          acct['uuid'] = SecureRandom.uuid
        end
      end
    end
    if @save
      @ok = @book.save
      Account.create(accounts_array)
    else
      @ok = false
    end
    return self
  end 


  def new_book
    book_id = Book.maximum(:id) + 1
    @book = Book.new(id:book_id,name: @book_name)
    @book.root = SecureRandom.uuid
    @book.assets = SecureRandom.uuid
    @book.liabilities = SecureRandom.uuid
    @book.equity = SecureRandom.uuid
    @book.income = SecureRandom.uuid
    @book.expenses = SecureRandom.uuid
    @book.checking = SecureRandom.uuid
    @book.savings = SecureRandom.uuid
    @book.settings = {skip:true}.with_indifferent_access
  end


end