class Amount

  def self.to_money(int,unit="")
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    helper.number_to_currency(amt,unit:unit)
  end

  def self.money(int,unit="")
    self.to_money(int,unit="")
  end

  def self.to_fixed(int,unit="")
    return '' if int.nil? || int.zero?
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    helper.number_to_currency(amt,unit:unit,delimiter:'')
  end

  def self.helper
    Helper.instance
  end


  class Helper
    include Singleton
    include ActionView::Helpers::NumberHelper
  end

end