module Vfw
  class Beer < SalesItem
    def self.model_name
      SalesItem.model_name
    end

    def current_bottles
      btls = (self.size * (self.cases || 0)) + (self.bottles_1 || 0) + (self.bottles_2.to_i || 0)
    end

    def get_cases
      cases = (self.quanity / self.size).to_i
    end

    def get_bottles
      bottles = self.quanity - (get_cases * self.size)
    end

    def buy_beer(params)
      cases = params[:cases].to_i
      total_cost = quanity * cost
      quanity_added = (cases * self.size).to_i
      buy_cost = (params[:purchase_price].to_f / quanity_added).round(2)
      total_new = buy_cost * quanity_added
      self.quanity += quanity_added
      self.cost = ((total_cost + total_new) / self.quanity).round(2)
      self
    end

    def self.update_beer(params)
      params[:beer].each do |id,val|
        if val[:total].present?
          beer = Beer.find(id)
          val[:quanity] = val[:total]
          beer.update(val)
        end
      end
    end



  end
end