module Vfw
  class Deposit < ApplicationRecord
    has_many :sales_revenues, inverse_of: :deposit, dependent: :destroy
    has_many :other_revenues, inverse_of: :deposit, dependent: :destroy
    has_many :cash_outs, inverse_of: :deposit, dependent: :destroy
    has_many :revenues, inverse_of: :deposit, dependent: :destroy

    accepts_nested_attributes_for :other_revenues, :reject_if =>  proc { |a| a[:item].blank? }, :allow_destroy => true
    accepts_nested_attributes_for :sales_revenues,allow_destroy: true #, :reject_if =>  proc { |a| a[:item].blank? }, :allow_destroy => true
    accepts_nested_attributes_for :cash_outs, allow_destroy:true  #, :reject_if =>  proc { |a| a[:item].blank? }, :allow_destroy => true

    validates_uniqueness_of :date

    RevenueClasses = %w(Beer Beverage Liquor Food Wine)
    SalesClasses = {Beer:{amt:2.0,tax:0.1},Beverage:{amt:1.0,tax:0.1},Food:{amt:1.0,tax:0.1},Liquor:{amt:3.0,tax:0.17},Wine:{amt:3.5,tax:0.1}}

    def self.deposit_totals(dids)
      deposits = Deposit.where(id:dids)
      totals = {}
      totals[:sales_revenue] = deposits.sum(:sales_revenue)
      totals[:credit_sales] = deposits.sum(:credit_sales)
      totals[:cash_sales] = totals[:sales_revenue] - totals[:credit_sales]
      totals[:tips_paid] = deposits.sum(:tips_paid)
      totals[:cash_out] = deposits.sum(:cash_out)
      totals[:sales_deposit] = deposits.sum(:sales_deposit)
      totals[:cash_payments] = totals[:sales_revenue] - totals[:credit_sales] + totals[:tips_paid]
      totals[:cash_expected] = totals[:cash_payments] - totals[:cash_out] - totals[:tips_paid]
      totals[:over_under] = totals[:sales_deposit] - totals[:cash_expected]
      totals[:other_deposit] = deposits.sum(:other_deposit)
      totals[:total_deposit] = deposits.sum(:total_deposit)
      totals
    end

    def cash_payments
      self.sales_revenue - self.credit_sales + self.tips_paid
    end

    def cash_sales
      self.sales_revenue - self.credit_sales
    end

    def cash_expected
      self.cash_payments - self.tips_paid - self.cash_out
    end

    def cash_counted
      self.sales_deposit
    end

    def over_under
      self.cash_counted - self.cash_expected
    end

    def update_other(params)
      self.other_deposit = self.other_revenues.sum(:amount)
      self.other_revenue = self.other_deposit
      self.total_deposit = sales_deposit + other_deposit
      self.save 
    end

    def sales_ledger_deposit
      deposit = self
      ledger = {debits:{},credits:{}}
      ledger[:debits] = [['General Fund',deposit.sales_deposit,'']]
      ledger[:credits] = [['Sales:Income','',deposit.sales_revenue]]
      if deposit.credit_sales > 0
        ledger[:debits] <<['Credit:Receivable',deposit.credit_sales,'']
      end
      if deposit.cash_out > 0
        ledger[:debits] <<['Misc Canteen:Expense',deposit.cash_out,'']
      end
      unless deposit.over_under.zero?
        if deposit.over_under > 0
          ledger[:credits] << ['Over Other:Income','',deposit.over_under]
        else
          ledger[:debits] << ['Under Other:Income',deposit.over_under * -1,'']
        end
      end

      ledger
    end

    def other_ledger_deposit
      others = self.other_revenues
      ledger = {debits:[],credits:[]}
      fund_acct_pointer = OtherRevenue.fund_type_acct
      funds = fund_acct_pointer[:funds]
      pointers = fund_acct_pointer[:pointers]
      accts = fund_acct_pointer[:accts]
      others.each do |rev|
        # p rev
        # p "item #{rev.item}"
        lookup = fund_acct_pointer[:pointer][rev.item]
        # p "lookup #{lookup}"
        # h[:funds][h[:pointer]['Coffee']['fund']]
        funds[lookup["fund"]] += rev.amount
        accts[lookup['acct']] += rev.amount
      end
      funds.each do |fund,amt|
        unless amt.zero?
          ledger[:debits] << [fund,amt,'']
        end
      end
      accts.each do |acct,amt|
        unless amt.zero?
          ledger[:credits] << [acct,'',amt]
        end
      end
      ledger
    end

    def combined_ledger_deposit
      sledger = sales_ledger_deposit
      oledger = other_ledger_deposit
      ledger = {debits:[],credits:[]}
      sledger[:debits].each do |d|
        ledger[:debits] << d
      end
      oledger[:debits].each do |d|
        ledger[:debits] << d
      end
      sledger[:credits].each do |d|
        ledger[:credits] << d
      end
      oledger[:credits].each do |d|
        ledger[:credits] << d
      end
      ledger
    end


    def self.update_liquor(params)
      liquor_path = Rails.root.join('yaml/inventory/liquor.yaml')
      liquor = {}
      params['deposit']["liquor"].each do |h|
        liquor[h[0]] = h[1]
      end
      yaml = liquor.to_yaml
      File.write(liquor_path,yaml)
    end

    def self.update_beer(params)
      beer_path = Rails.root.join('yaml/inventory/beer.yaml')
      beer = {}
      params['deposit']["beer"].each do |h|
        beer[h[0]] = h[1]
      end
      yaml = beer.to_yaml
      File.write(beer_path,yaml)
    end

  end
end