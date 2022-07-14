module ProfitLossHelper
  def pl_array(report)
    if report['options'][:level].to_i > report['options'][:max_level].to_i
      @level = report['options'][:max_level].to_i
    else
      @level = report['options'][:level].to_i
    end
    @level = 2 if @level == 1
    @array = []
    @max_level =  report['options'][:max_level].to_i
    da = new_row("Income")
    da[@level+1] = "Increase"
    @array << da
    children_array(report["Income"][:children])
    da = new_row("Total Income")
    da[@level+1] = to_money(report["Income"][:total],'$')
    @array << da
    da = new_row("Expense")
    da[@level+1] = "Decrease"
    @array << da
    children_array(report["Expense"][:children])
    da = new_row("Total Expense")
    da[@level+1] = to_money(report["Expense"][:total],'$')
    @array << da
    da = new_row("Profit(+)/Loss(-)")
    da[@level+1] =to_money(report["Income"][:total] - report["Expense"][:total],"$")
    @array << da

    @array
  end

  def children_array(kids)
    kids.each do |k,v|
      if v[:children].blank?
        # puts "children blank #{v[:amount]}"
        if  v[:amount] != 0
          da = new_row(k,v[:level])
          da[@level - v[:level] + 2 ] = to_money(v[:amount],'$')
          @array << da
        end
        # puts "children blank end #{k}" 

      else
        if v[:level] == @level
          unless v[:total].zero?
            da = new_row(k,v[:level])
            da[@level - v[:level] + 2 ] = to_money(v[:amount] + v[:total],'$')
            @array << da
          end
        else
          unless v[:total].zero? 
            da = new_row(k,v[:level])
            @array << da

            children_array(v[:children])
            da = new_row("Total "+k,v[:level])
            da[@level - v[:level] + 2 ] = to_money(v[:amount] + v[:total],'$')
            @array << da
          end

        end

      end
    end
  end

  def new_row(desc,lev=nil)
    a = Array.new(@level + 2)
    a[0] = desc
    a[1] = lev
    a
  end
  
end