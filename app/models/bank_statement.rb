class BankStatement < ApplicationRecord
  belongs_to :book
  serialize :hash_data, HashWithIndifferentAccess
  # attribute :statement_date, :date
  # attribute :ending_balance, :decimal
  # attribute :beginning_balance, :decimal
  attribute :bank

  # after_find do |bs|
  #   bs.statement_date = bs.hash_data[:statement_date]
  #   bs.beginning_balance = Cash.to_fixed(bs.hash_data[:beginning_balance])
  #   bs.ending_balance = Cash.to_fixed(bs.hash_data[:ending_balance])
  # end

  # def update_statement(params)
  #   self.hash_data = {
  #     beginning_balance: params[:beginning_balance].gsub(/\D/,'').to_i,
  #     ending_balance: params[:ending_balance].gsub(/\D/,'').to_i,
  #     statement_date: Date.parse(params[:statement_date])
  #   }.with_indifferent_access
  #   self.text_data = params[:text_data]
  #   self.save
  # end

  def reconcile
    self.bank = Bank.new(self.statement_date).reconcile(self)
  end

end
