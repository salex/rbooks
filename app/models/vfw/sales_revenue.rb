 module Vfw
  class SalesRevenue < Vfw::Revenue
    attribute :tax, :float
    attribute :average, :float
    attribute :net_sales, :float

    # after_initialize do |r|
    #   puts "sales initialized"
    #   if r.item.present?
    #     val =  Deposit::SalesClasses[r.item.to_sym]
    #     puts "val #{val}"
    #     self.tax = val[:tax]
    #     self.average = val[:amt]
    #   else
    #     puts r.inspect
    #   end
    # end

   
    def self.sales_revenue_totals(dids)
      sales = SalesRevenue.where(deposit_id:dids)
      items = sales.pluck(:item).uniq
      obj = {}
      items.each do |i|
        rsales = sales.where(item:i)
        obj[i] = {quanity:rsales.sum(:quanity),amount:rsales.sum(:amount)}
      end
      obj
    end

    def set_attributes
      if self.item.present?
        val =  Deposit::SalesClasses[self.item.to_sym]
        self.tax = val[:tax]
        self.average = val[:amt]
      end
    end


    def net_to_sales(net)
      val =  Deposit::SalesClasses[self.item.to_sym]
      gross = (((net * (1 + self.tax))*100).to_i / 25) * 0.25

    end

  end
end