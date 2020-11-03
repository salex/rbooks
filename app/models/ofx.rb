class Ofx < BankStatement
  attribute :acct
  attribute :balance
  attribute :beginning_balance
  attribute :tran_range
  attribute :fit_range
  attribute :uncleared_entries
  attribute :linked_entries
  attribute :key
  require "ofx"

  def upload_io(io)
    self.ofx_data = io.read
    self.key = io.original_filename
    update_data
    self.ending_balance = self.balance
    self.save
  end

  def ofx_account
    # parse OFX unless its already been parsed
    if self.acct.nil?
      self.acct = OFX(self.ofx_data).account
    end
    self.acct
  end

  def update_data(set_ref=false)
    fields = {}.with_indifferent_access
    o = ofx_account
    self.balance = fields[:balance] = o.balance.amount_in_pennies
    fields[:available_balance] = o.available_balance.amount_in_pennies
    fields[:balance_date] = o.balance.posted_at.to_date
    from = o.transactions.last.posted_at.to_date
    to = o.transactions.first.posted_at.to_date
    fit_start = o.transactions.last.fit_id
    fit_end = o.transactions.first.fit_id
    fields[:diff] = o.transactions.collect{|t| t.amount_in_pennies}.sum
    self.beginning_balance = fields[:beginning_balance] =  fields[:balance] - fields[:diff]
    self.tran_range = fields[:tran_range] = from..to
    self.fit_range = fields[:fit_range] = fit_start..fit_end

    self.hash_data = fields
    # self.date = to
    if set_ref
      set_encleared_entries
      set_ref_number
      set_linked_entries
     end
    return self
  end

  def set_ref_number
    ofx_account.transactions.each do |t|
      entry = Entry.find_by(fit_id: t.fit_id)
      if entry.present?
        t.ref_number = entry.id 
      else
        t.payee = unlinked_entries(t)
      end
    end
  end

  def set_linked_entries
    self.linked_entries = Entry.where(Entry.arel_table[:fit_id].between(self.hash_data[:fit_range]))
  end


  def set_encleared_entries
    banking = Bank.new
    self.uncleared_entries = banking.all_uncleared_entries
  end

  def unlinked_entries(tran)
    se = self.uncleared_entries.select{|e| tran.amount_in_pennies == e.amount}
    links = {}.with_indifferent_access
    se.each do |e|
      append_links(links,e,tran)
    end
    links
  end

  def append_links(links,e,t)
    if links[t.fit_id].present?
      links[t.fit_id] << {amount: t.amount_in_pennies,numb:t.check_number,
        enumb:e.numb,entry_id:e.id,description:e.description,post_date: e.post_date.to_formatted_s(:number)}
    else
      links[t.fit_id] = [{amount: t.amount_in_pennies,numb:t.check_number,
        enumb:e.numb,entry_id:e.id,description:e.description,post_date: e.post_date.to_formatted_s(:number)}]
    end
  end
  
  def dup_entries
    @to = Date.today
    desc = Current.book.entries.where(post_date:((@to -90.days)..@to)).pluck(:description)
    ndesc = desc.map{|i| i.split(/ /)[0..3].join(' ')}.uniq.sort_by(&:downcase)
  end

  def self.date_in_range(date)
    date = Ledger.set_date(date)
    Current.book.ofxes.order(:statement_date).reverse_order.each do |o|
      return o if o.hash_data[:tran_range].cover?(date)
    end 
    nil
  end

  def self.fit_in_range(fit_id)
    Current.book.ofxes.order(:statement_date).reverse_order.each do |o|
      return o if o.hash_data[:fit_range].cover?(fit_id)
    end 
    nil
  end

  def self.find_fit_id(fit_id)
    o = Current.book.ofxes.fit_in_range(fit_id)
    return nil if o.nil?
    trans = o.ofx_account.transactions.select{|t| t.fit_id == fit_id}.first
  end

end
