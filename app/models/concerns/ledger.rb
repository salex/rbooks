module Ledger
  def self.set_date(date)
    return date if date.class == Date
    return Date.today if date.blank?
    Date.parse(date) rescue Date.today
  end

  def self.money(int,sign="")
    int = 0 if int.blank?
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    set_zero = sprintf('%.2f',amt) # now have a string to 2 decimals
    sign+set_zero.gsub(/(\d)(?=(\d{3})+(?!\d))/, "\\1,") # add commas
  end

  def self.to_money(int,sign="")
    self.money(int,sign="")
  end

  def self.to_fixed(int)
    return '' if int.nil? || int.zero?
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    set_zero = sprintf('%.2f',amt) # now have a string to 2 decimals
  end

  def self.get_checking_acct_id
    Current.book.settings[:checking_acct_id]
  end

  def self.get_checking_acct_ids
    Current.book.settings[:checking_ids]
  end

  def self.statement_range(date)
    date = Ledger.set_date(date)
    bom = date.beginning_of_month
    eom = date.end_of_month
    bos = bom.on_weekend? || bom.wday == 1 ? bom.prev_weekday + 1.day : bom
    eos = eom.on_weekend? ? eom.prev_weekday  : eom
    bos..eos
  end

  def self.ledger_entries(family,range)
    # entry_ids = Entry.where(post_date: range)
    #   .joins(:splits)
    #   .where(post_date: range, splits: { account_id: family })
    #   .select('entries.id')
    #   .distinct

    # Entry.where(id: entry_ids).includes(:splits).order(:post_date,:numb)

    Entry.where_assoc_exists(:splits,{ account_id: family})
      .where(post_date: range)
      .includes(:splits)
      .order(:post_date, :numb).distinct

  end

  def self.last_entry_date(family)
    Entry.where_assoc_exists(:splits,{ account_id: family})
    .includes(:splits)
    .order(:post_date).last.post_date
  end

  def self.entries_ledger(entries)
    # this is only for seach ledgers, not account ledgers
    bal = @balance ||= 0
    # kjdfjd = kljdfldj
    lines = [{id: nil,date: nil,numb:nil,desc:"Beginning Balance",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:bal}]
    entries.each do |t|
      date = t.post_date
      line = {id: t.id,date: date.strftime("%m/%d/%Y"),numb:t.numb,desc:"#{t.description}",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:0,split_cnt:0}
      # p "EEEEEE #{t.splits.count}"
      t.splits.each do |s|
        line[:split_cnt] += 1
        details = s.details
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

end
