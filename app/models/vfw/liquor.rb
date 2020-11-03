module Vfw

  class Liquor < Vfw::SalesItem


    def self.model_name
      SalesItem.model_name
    end

    def unit_cost
      if self.purchase_price.present?
        shots = (size / 35.51638).to_i
        self.cost = (purchase_price / shots).round(2)
      end
    end

    def get_ml
      ml = self.quanity * 35.51638
    end

    def get_bottles
      bottles = (get_ml / self.size).to_i
    end

    def get_percent
      percent = (((get_ml - (get_bottles * self.size)) / self.size) * 100).to_i
    end

    def get_shots
      # shots are (bottle * size ) + (percent * size) 
      ml = (self.size * (self.bottles || 0)) + (self.size * ((self.percent || 0)) / 100.0)
      shots = (ml / 35.51638).to_i
    end

    def buy_liquor(params)
      ml = params[:size].to_i # param size might be differet the default size, out of liters bought 750ml
      btls = ml / self.size 
      total_cost = quanity * cost # cost prior to purchase, which may adjust the price
      quanity_added = (ml / 35.51638).to_i
      buy_cost = (params[:purchase_price].to_f / quanity_added).round(2)
      total_new = buy_cost * quanity_added
      self.quanity += quanity_added
      self.bottles += btls
      self.cost = ((total_cost + total_new) / self.quanity).round(2)
      self
    end

    def self.update_liquor(params)
      params[:liquor].each do |id,val|
        if val[:total].present?
          liquor = Liquor.find(id)
          val[:quanity] = val[:total]
          liquor.update(val)
        end
      end
    end

  end
end
