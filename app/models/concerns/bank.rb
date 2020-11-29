class Bank

  attr_accessor :checking_ids,
    :checking_account,
    :closing_date,
    :reconciled_balance,
    :cleared_entries,
    :cleared_balance,
    :uncleared_entries,
    :uncleared_balance,
    :closing_balance,
    :balance, 
    :statement_range, 
    :checking_ending_balance,
    :checking_beginning_balance,
    :bank_beginning_balance,
    :bank_ending_balance,
    :range_reconciled_balance,
    :reconcile_diff,
    :cleared_splits


  def initialize(closing_date=nil,closing_balance=nil)
    self.closing_date = Ledger.set_date(closing_date)
    if closing_balance.blank?
      self.closing_balance = 0
    else
      self.closing_balance = closing_balance.to_s.gsub(/\D/,'').to_i
    end
    set_checking_ids
  end

  def checkbook_balance
    set_balances
    self.balance = self.reconciled_balance + self.cleared_balance + self.uncleared_balance
    return self
  end

  def reconcile(bank_statement)
    checkbook_balance
    self.statement_range = Ledger.statement_range(self.closing_date)
    self.checking_ending_balance = checking_account.closing_family_balance_on(self.closing_date)
    self.checking_beginning_balance = checking_account.family_balance_on(statement_range.first)
    self.bank_beginning_balance = bank_statement.beginning_balance
    self.bank_ending_balance = bank_statement.ending_balance ||= 0
    set_range_reconciled_balance
    test_balance = checking_ending_balance  -  uncleared_balance - range_reconciled_balance
    self.reconcile_diff = test_balance - bank_ending_balance
    return self
  end

  def all_uncleared_entries
    splits = Split.where(reconcile_state:'n',account_id:checking_ids).
    joins(:entry).
    order(Entry.arel_table[:post_date],Entry.arel_table[:numb])
    entries = split_entries(splits)
  end

  def cleared_splits
    splits = Split.where(reconcile_state:'c',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].lteq(closing_date)).
    order(Entry.arel_table[:post_date],Entry.arel_table[:numb])
    self.cleared_balance = splits.sum(:amount)
    self.cleared_splits = splits
  end



  private

  def set_checking_ids
    self.checking_account = Current.book.checking_acct
    self.checking_ids = Current.book.settings[:checking_ids] 
    # if checking account does not have childeren, it's just the account
    self.checking_ids = self.checking_account if self.checking_ids.blank?
  end

  def set_reconciled_balance
    self.reconciled_balance = Split.where(reconcile_state:'y',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].lteq(closing_date)).sum(:amount)
  end

  def set_range_reconciled_balance
    self.range_reconciled_balance = Split.where(reconcile_state:'y',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].between(statement_range)).sum(:amount)
  end

  def set_cleared_entries
    self.cleared_entries = split_entries(cleared_splits)
  end

  def set_uncleared_entries
    self.uncleared_entries = split_entries(uncleared_splits)
  end

 
  def uncleared_splits
    splits = Split.where(reconcile_state:'n',account_id:checking_ids).
    joins(:entry).where(Entry.arel_table[:post_date].lteq(closing_date)).
    order(Entry.arel_table[:post_date],Entry.arel_table[:numb])
    self.uncleared_balance = splits.sum(:amount)
    splits
  end

  def split_entries(splits)
    entries = Entry.where(id:splits.pluck(:entry_id).uniq).order(:post_date,:numb)
    entries.each do |e|
      esplits = e.splits.where(account_id:checking_ids)
      rstate = esplits.pluck(:reconcile_state).uniq
      case rstate
      when %w{v}
        e.reconciled = 'v'
      when %w{y}
        e.reconciled = 'y'
      when %w{n}
        e.reconciled = 'n'
      when %w{c}
        e.reconciled = 'c'
      else
        e.reconciled = '?'
        # this is an error, have not seen it happen. any blank state should be set to 'n'
      end
      e.amount = esplits.sum(:amount)
    end
    entries
  end

  def set_balances
    set_reconciled_balance
    set_uncleared_entries
    set_cleared_entries
  end


end