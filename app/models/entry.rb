class Entry < ApplicationRecord
  belongs_to :book, default: -> { Current.book }
  validates_uniqueness_of :fit_id, allow_blank: true
  attribute :amount, :integer
  attribute :reconciled
  has_many :splits, -> {order(:account_id)},dependent: :destroy, inverse_of: :entry

  accepts_nested_attributes_for :splits, 
    :reject_if =>  proc { |att| att[:amount].to_i.zero? && att[:account_id].to_i.zero?},
    allow_destroy: true

  def valid_params?(params_hash)
    split_sum = 0
    params_hash[:splits_attributes].each{|k,s| split_sum += s[:amount].to_i if s[:_destroy].to_i.zero?}
    unless split_sum.zero?
      errors.add(:amount, "Unbalanced: debits, credits must balance")
      return false
    else
      return true
    end
  end

  def reconcile_state
    self.reconciled = self.splits.pluck(:reconcile_state).uniq
  end

  def reconciled?
    #if anything has 'y' consider reconciled
    reconcile_state.include?('y')
  end

  def cleared?
    #if anything has 'c' consider cleared
    reconcile_state.include?('c')
  end

  # THIS WAS REPLACE BY METHOD IN BANK CLASS
  # def set_banking_attributes
  #   # banking attributes only really needed with reconciling a bank account
  #   banking_splits = self.splits.where(account_id:Current.book.settings[:checking_ids])
  #   if banking_splits.present?
  #     reconcile_state = banking_splits.pluck(:reconcile_state).uniq
  #     self.amount = banking_splits.sum(:amount)
  #     case reconcile_state
  #     when %w{v}
  #       self.reconciled = 'v'
  #     when %w{y}
  #       self.reconciled = 'y'
  #     when %w{n}
  #       self.reconciled = 'n'
  #     when %w{c}
  #       self.reconciled = 'c'
  #     else
  #       self.reconciled = '?'
  #       # this is an error, have not seen it happen. any blank state should be set to 'n'
  #     end
  #   end
  # end

  def duplicate
    new_entry = self.dup
    new_entry.numb = nil
    new_entry.fit_id = nil
    new_entry.post_date = Date.today
    self.splits.each do |s|
      s_attr = s.attributes.symbolize_keys.except(:id,:created_at,:updated_at,:reconcile_date,:reconcile_state)
      new_entry.splits.build(s_attr)
    end
    new_entry.splits.build()
    new_entry   
  end

  def duplicate_with_bank(bank)
    new_entry = self.dup
    new_entry.numb = bank.check_number unless bank.check_number.to_i > 9000
    new_entry.post_date = bank.posted_at.to_date
    new_entry.fit_id = bank.fit_id
    amount = bank.amount_in_pennies
    # need to replace debit, credit and amount to bank stuff
    # since only two splits allowed, use amount from bank to set debits and credits
    # flip amount after first split
    self.splits.each do |s|
      s_attr = s.attributes.symbolize_keys.except(:id,:created_at,:updated_at,:reconcile_date,:reconcile_state)
      s.amount = amount
      set_debit_credit(s)
      s_attr[:debit] = s.debit
      s_attr[:credit] = s.credit
      s_attr[:amount] = s.amount

      s_attr[:reconcile_state] = 'c'
      new_entry.splits.build(s_attr)
      amount = amount * -1
    end
    new_entry.splits.build()
    new_entry   
  end

  def link_ofx_transaction(fit_id)
    checking_ids = Current.book.settings[:checking_ids]
    s = self.splits.where(account_id:checking_ids, reconcile_state:['n','c'])
    s.update_all(reconcile_state:'c') if s.present?
    self.update(fit_id:fit_id)
  end

  def set_debit_credit(s)
    if s.amount.blank?
      s.amount = 0
    end
    if s.amount < 0
      s.credit = s.amount * -1
      s.debit = 0
    else
      s.credit = 0
      s.debit = s.amount
    end
  end

end

