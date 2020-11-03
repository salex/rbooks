module Vfw
  class OtherRevenue < Vfw::Revenue
    # def self.model_name
    #   Revenue.model_name
    # end

    Items = {
      Coffee:{acct:'General:Income:DuesDonation'},
      Dance:{acct:'General:Income:Event'},
      Karaoke:{acct:'General:Income:Event'},
      PhoneCard:{acct:'General:Income:AmusementDonate'},
      Amusement:{acct:'General:Income:AmusementDonate'},
      Canteen:{acct:'General:Income:AmusementDonate'},
      Food:{acct:'General:Income:Donations'},
      Event:{acct:'General:Income:Event'},
      Rounding:{acct:'General:Income:Other'},
      Vending:{acct:'General:Income:Other Income'},
      Recycle:{acct:'General:Income:Other Income'},
      Kitchen:{acct:'General:Income:Event'},
      Rental:{acct:'General:Income:Event'},
      Donation:{acct:'General:Income:Donation'},
      General:{acct:'General:Income:Other Income'},
      Relief:{acct:'Relief:Income:Donations'},
      BuddyPoppy:{acct:'Relief:Income:Buddy Poppy'},
      DuesPost:{acct:'General:Income:Dues Income'},
      DuesNat:{acct:'General:Liabiliities:Dues Payable'},
      Reserve:{acct:'Reserve:Income:Other Income'},
      Building:{acct:'Building:Income:Donation'},
      Temporary:{acct:'Temporary:Income:Other Income'},
      Other:{acct:'General:Income:Other Income'},
      Misc:{acct:'General:Income:Other Income'}
    }.with_indifferent_access


    def self.items_select
      keys = Items.keys
      [''] + keys
    end

    def self.item_values
      keys = Items.keys
      values = []
      keys.each do |k|
        values << "#{k}:#{Items[k][:acct]}"
      end
      values
    end

    def self.fund_type_acct
      h = {}.with_indifferent_access
      Items.each do |k,v|
        elem = v[:acct].split(':')
        h[k] = {fund:elem[0],type:elem[1],acct:elem[2]}
      end
      fund_keys =  h.each.map{|k,d| d[:fund]}.uniq
      type_keys =  h.each.map{|k,d| d[:type]}.uniq
      acct_keys =  h.each.map{|k,d| d[:acct]}.uniq
      funds = {}.with_indifferent_access
      accts = {}.with_indifferent_access
      fund_keys.each{|k| funds[k] = 0.0}
      acct_keys.each{|k| accts[k] = 0.0}
      results = {funds:funds,accts:accts,pointer:h}
    end

  end
end