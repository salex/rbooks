class Split < ApplicationRecord
  belongs_to :entry, inverse_of: :splits
  belongs_to :account

  attribute :debit, :integer
  attribute :credit, :integer
  attribute :transfer, :string

  validates_associated :account
  validates_associated :entry

  after_find do |split|
    set_debit_credit(split) if Current.book.present?
  end

  def details
    return {name:transfer,cr:self.credit,db:self.debit,
      amount:self.amount, action: self.action, memo:self.memo, 
      r:self.reconcile_state, acct_id:self.account_id}
    # return {name:transfer,cr:self.credit,db:self.debit,
    #   amount:self.amount,money:self.moneyize, action: self.action, memo:self.memo, 
    #   r:self.reconcile_state, acct_id:self.account_id}

  end

  # def moneyize
  #   {debit:to_money(self.debit),credit:to_money(self.credit),amount:to_money(self.amount)}.with_indifferent_access
  # end

  private

  # def to_money(int)
  #   dollars = int / 100
  #   cents = (int % 100) / 100.0
  #   amt = dollars + cents
  #   set_zero = sprintf('%.2f',amt) # now have a string to 2 decimals
  # end

  def set_debit_credit(s)
    self.transfer =  Current.book.settings[:transfers][s.account_id]
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
