module AmountHelper
  def to_money(pennies,unit="")
    pennies = 0 if pennies.blank?
    dollars = pennies / 100
    cents = (pennies % 100) / 100.0
    amt = dollars + cents
    number_to_currency(amt,unit:unit)
  end

  def money(pennies,unit="")
    self.to_money(pennies,unit="")
  end

  def to_fixed(pennies,unit="")
    return '' if pennies.nil? || pennies.zero?
    dollars = pennies / 100
    cents = (pennies % 100) / 100.0
    amt = dollars + cents
    number_to_currency(amt,unit:unit,delimiter:'')
  end

  def dmoney(decimal,unit="")
    return 0 if decimal.blank? || decimal.zero?
    number_to_currency(decimal,unit:unit)
  end


end