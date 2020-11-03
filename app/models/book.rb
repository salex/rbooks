class Book < ApplicationRecord

  has_many :accounts, dependent: :destroy
  has_many :entries, dependent: :destroy
  has_many :bank_statements, dependent: :destroy
  has_many :ofxes

  serialize :settings, HashWithIndifferentAccess
  attribute :recent


  def build_tree
    new_tree = []
    troot = self.accounts.find_by(uuid:root)
    troot.walk_tree(0,new_tree)
    new_tree.each do |a| 
      if a.level_changed?
        a.save
      end
    end
    new_tree
  end

  def destroy_book
    self.entries.destroy_all
    # self.bank_statements.destroy_all
    self.accounts.destroy_all
    self.destroy
  end


  def root_acct
    self.accounts.find_by(uuid:self.root)
  end

  def checking_acct
    self.accounts.find_by(uuid:self.checking)
  end

  def assets_acct
    self.accounts.find_by(uuid:self.assets)
  end

  def liabilities_acct
    self.accounts.find_by(uuid:self.liabilities)
  end

  def equity_acct
    self.accounts.find_by(uuid:self.equity)
  end

  def income_acct
    self.accounts.find_by(uuid:self.income)
  end

  def expenses_acct
    self.accounts.find_by(uuid:self.expenses)
  end

  def savings_acct
    self.accounts.find_by(uuid:self.savings)
  end

  def current_assets
    self.accounts.find_by(name:'Current')
  end



  def get_settings
    return {}.with_indifferent_access if self.settings[:skip].present? # on create new book
    reset = (Rails.application.config.x.acct_updated > self.updated_at.to_s || self.settings.blank?)
    # puts "DEBUG conf #{Rails.application.config.x.acct_updated}"
    # puts "DEBUG at #{self.updated_at.to_s}"
    # puts "DEBUG blank #{self.settings.blank?}"
    # puts "DEBUG reset #{reset}"

    if reset
      checking = checking_acct
      new_settings = {}.with_indifferent_access
      accts = build_tree
      id_trans = accts.pluck(:id,:transfer)
      if checking.present?
        new_settings[:checking_acct_id] = checking.id 
        new_settings[:checking_ids] = checking.leaf
      end
      new_settings[:transfers] = id_trans.to_h
      new_settings[:tree_ids] = new_settings[:transfers].keys
      new_settings[:acct_sel_opt] = id_trans.map{|i| i.reverse}.prepend(['',0])
      new_settings[:dis_opt] = accts.select{|a| a.placeholder}.pluck(:id)
      new_settings[:acct_sel_opt_rev] = new_settings[:acct_sel_opt].
        select{|i| i  unless new_settings[:dis_opt].include?(i[1])}.
        map{|i|[ i[0].split(':').reverse.join(':'),i[1]]}.
        sort_by { |word| word[0].downcase }
      self.settings = new_settings
      self.touch
      self.save!
    end
    return self.settings
  end

  def last_numbers(ago=6)
    from = Date.today.beginning_of_month - ago.months
    nums = self.entries.where(Entry.arel_table[:post_date].gteq(from)).pluck(:numb).uniq.sort.reverse
    obj = {numb: 0} # for numb only
    nums.each do |n|
      if n.blank? 
        next # not blank or nil
      end
      key = n.gsub(/\d+/,'')
      val = n.gsub(/\D+/,'')
      next if key+val != n # only deal with key/numb not numb/key
      is_blk  = val == '' # key only
      num_only = val == n
      if !is_blk
        val = val.to_i
        is_num = true
      else
        is_num = false
      end
      if num_only
        obj[:numb] = val if ((val > obj[:numb]) && (val < 9000))
        next
      end
      key = key.to_sym 
      unless obj.has_key?(key)
        obj[key] = val 
        next
      end
      if is_num
        obj[key] = val if val > obj[key]
        next
      else
        obj[key] = val 
      end
    end
    obj
  end

  def auto_search(params)
    desc = params[:q]
    entry_ids = self.entries.where(Entry.arel_table[:description].matches("#{desc}%"))
    .order(Entry.arel_table[:id]).reverse_order.pluck(:description,:id)
    filter = {}
    entry_ids.each do |a|
      description = a[0]
      id = a[1]
      filter[description] = id unless filter.has_key?(description)
    end
    filter
  end

  def description_lookup(ago=6)
    from = Date.today.beginning_of_month - ago.months
    entry_ids = self.entries.where(Entry.arel_table[:post_date].gteq(from)).order(:id).reverse_order
      .pluck(:description,:id)
    lookup = {}
    entry_ids.each do |e|
      lookup[e[0].downcase] = [e[0],e[1]] unless lookup.has_key?(e[0].downcase)
    end
    arr = []
    lookup.each{|k,v| arr << [k,v[1],v[0]]}
    arr.sort.map{|i| [i[2],i[1]]}
    # arr.pluck(2,1)
  end

  def contains_any_word_query(words,all=nil)
    words = words.split unless words.class == Array
    words.map!{|v| "%#{v}%"}
    query = self.entries.where(Entry.arel_table[:description].matches_any(words)).order(:post_date).reverse_order
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_all_words_query(words,all=nil)
    words = words.split unless words.class == Array
    words.map!{|v| "%#{v}%"}
    query = self.entries.where(Entry.arel_table[:description].matches_all(words)).order(:post_date).reverse_order
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_match_query(match,all=nil)
    query = self.entries.where(Entry.arel_table[:description].matches("%#{match}%")).order(:post_date).reverse_order
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_number_query(match,all=nil)
    # query = self.entries.where('entries.numb like ?',"#{match}%").order(:post_date).reverse_order
    query = self.entries.where(Entry.arel_table[:numb].matches("#{match}%")).order(:numb).reverse_order
    puts "query.count #{match}  #{query.count}"
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def contains_amount_query(match,all=nil)
    bacct_ids = self.settings[:tree_ids] - self.settings[:dis_opt]
    eids = Split.where(account_id:bacct_ids).where(amount:match.to_i).pluck(:entry_id).uniq
    # query = self.entries.where('entries.numb like ?',"#{match}%").order(:post_date).reverse_order
    query = self.entries.where(id:eids).order(:post_date).reverse_order
    puts "query.count #{match}  #{query.count}"
    return query if all.present?
    p = query.pluck(:description,:id)
    uids = p.uniq{ |s| s.first }.to_h.values
    query.where(id:uids).order(:post_date).reverse_order
  end

  def self.entries_ledger(entries)
    bal = @balance ||= 0

    lines = [{id: nil,date: nil,numb:nil,desc:"Beginning Balance",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:bal}]
    entries.each do |t|
      date = t.post_date
      line = {id: t.id,date: date.strftime("%m/%d/%Y"),numb:t.numb,desc:"#{t.description}",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:0}
      t.splits.each do |s|
        details = s.details

        # if kids.include?(details[:aguid]) 
          line[:checking][:db] += details[:db]
          line[:checking][:cr] += details[:cr]
          bal += details[:cr] 
          line[:balance] = bal
          line[:r] = details[:r]
        line[:details] << details
      end
      lines << line
    end
    lines
  end

  def create_book
    book = self
    book.root = SecureRandom.uuid
    book.assets = SecureRandom.uuid
    book.liabilities = SecureRandom.uuid
    book.equity = SecureRandom.uuid
    book.income = SecureRandom.uuid
    book.expenses = SecureRandom.uuid
    book.checking = SecureRandom.uuid
    book.savings = SecureRandom.uuid
    settings = {skip:true}
    book.save


    broot = book.accounts.create(  
      {:name=>"Root Account",
       :account_type=>"ROOT",
       :description=>"",
       :parent_id=>nil,
       :placeholder=>true,
       :level=>0,
       :uuid=>book.root
    })

    bassets = book.accounts.create(
      {:name=>"Assets",
      :account_type=>"ASSET",
      :description=>"",
      :parent_id=>broot.id,
      :placeholder=>true,
      :level=>1,
      :uuid=>book.assets
      })

    bliabilities = book.accounts.create(
      {:name=>"Liabilities",
      :account_type=>"LIABILITY",
      :description=>"",
      :parent_id=>broot.id,
      :placeholder=>true,
      :level=>1,
      :uuid=>book.liabilities
    })

    bequity = book.accounts.create(
      {:name=>"Equity",
      :account_type=>"EQUITY",
      :description=>"",
      :parent_id=>broot.id,
      :placeholder=>true,
      :level=>1,
      :uuid=>book.equity
    })

    bincome = book.accounts.create(
      {:name=>"Income",
      :account_type=>"INCOME",
      :description=>"",
      :parent_id=>broot.id,
      :placeholder=>true,
      :level=>1,
      :uuid=>book.income
    })

    bexpense = book.accounts.create(
      {:name=>"Expenses",
      :account_type=>"EXPENSE",
      :description=>"",
      :parent_id=>broot.id,
      :placeholder=>true,
      :level=>1,
      :uuid=>book.expenses
    })

    bchecking = book.accounts.create(
      {:name=>"Checking",
      :account_type=>"BANK",
      :description=>"",
      :parent_id=>bassets.id,
      :placeholder=>false,
      :level=>2,
      :uuid=>book.checking
    })

    bsaving = book.accounts.create(
      {:name=>"Savings",
      :account_type=>"BANK",
      :description=>"",
      :parent_id=>bassets.id,
      :placeholder=>false,
      :level=>2,
      :uuid=>book.savings
    })
    self.settings = {}
    self.save
    self.get_settings
    true

  end

end

