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

  def self.to_amount(str)
    # string represention on money may have $ , or . characters
    # $1,999.23, 1,999.23, 1,999.237, 1999.2 1999

    dollars,cents = str.split('.')
    dollars = dollars.gsub(/\D/,'')
    return dollars.to_i if cents.blank? # $1,999  no cents but maybe $ or ,
    cents += '0' if cents.size == 1 # seen ofx have thing like 212.2 for 20 cents
    if cents.size > 2
      #integer round to 2 places
      cents = (cents.to_i + 5).to_s[0..1]
    end
    amt = (dollars+cents).to_i
  end

  def self.to_pennies(str)
    self.to_amount(str)
  end
  
  def self.helper
    Helper.instance
  end


  class Helper
    include Singleton
    include ActionView::Helpers::NumberHelper
  end

end