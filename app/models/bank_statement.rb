class BankStatement < ApplicationRecord
  belongs_to :book

  serialize :hash_data, HashWithIndifferentAccess
  attribute :bank

  def reconcile
    self.bank = Bank.new(self.statement_date).reconcile(self)
  end

end
