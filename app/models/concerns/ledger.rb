module Ledger
  include  ActionView::Helpers::NumberHelper

  def self.set_date(date)
    return date if date.class == Date
    return Date.today if date.blank?
    Date.parse(date) rescue Date.today
  end

  def self.from_to_as_range(from,to)
    from = Ledger.set_date(from)
    to = Ledger.set_date(to)
    from..to
  end

  def self.donations(range)
    family = [32,28,29,30,25]
    donation_entries = ledger_entries(family,range)
    bal = @balance ||= 0
    lines = [{id: nil,date: nil,numb:nil,desc:"Beginning Balance",
        checking:{db:0,cr:0},details:[], memo:nil,r:nil,balance:bal}]
    donation_entries.each do |t|
      date = t.post_date
      t.splits.each do |s|
        if family.include?(s.account_id)
          line = {id: t.id,date: date.strftime("%m/%d/%Y"),numb:t.numb,desc:"",acct:nil,
            checking:{db:0,cr:0},details:[],r:nil,balance:0,split_cnt:0}
          line[:split_cnt] += 1
          line[:desc] = "#{t.description} - #{s.memo}"
          details = s.details
          line[:acct] = details[:name]
          line[:r] = details[:r]
          line[:checking][:db] += details[:db]
          line[:checking][:cr] += details[:cr]
          bal += details[:cr] 
          line[:balance] = bal
          line[:r] = details[:r]
          lines << line
        end
      end
    end
    lines
  end

  def self.dates_in_same_month(date1,date2)
    date1.month == date2.month && date1.year == date2.year
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
