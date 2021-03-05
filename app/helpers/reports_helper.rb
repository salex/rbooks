module ReportsHelper

  def tree_summary(summary)
    @summary = summary
    key = summary.keys.first
    @tree = []
    append_children(key)
    @tree
  end

  def append_children(key)
    @tree << key
    node = @summary[key]
    node[:children].each do |c|
      append_children(c)
    end
  end

  def profit_loss_report(report)
    @level = report['options'][:level].to_i
    content_tag(:div,class:'') { 
      @pad = 0
      concat( tot_row("Income",'',"Increase"))
      @pad = 1
      children(report["Income"][:children])
      concat(tot_row("Total Income",imoney(report["Income"][:total],"$")))
      @pad = 0
      concat( tot_row("Expenses",'','Decrease'))
      @pad = 1
      children(report["Expense"][:children])
      concat( tot_row("Total Expenses",imoney(report["Expense"][:total],"$")))
      concat( tot_row("Profit(+)/Loss(-)",imoney(report["Income"][:total] - report["Expense"][:total],"$")))
    }
  end

  def trial_balance_report(report)
    @level = report['options'][:level].to_i
    content_tag(:div) { 
      @pad = 0
      concat( tot_row("Assets",'',"Increase"))
      @pad = 1
      children(report["Assets"][:children])
      concat(tot_row("Total Assest",imoney(report["Assets"][:total],"$")))

      @pad = 0
      concat( tot_row("Liabilities",'',"Increase"))
      @pad = 1
      children(report["Liabilities"][:children])
      concat(tot_row("Total Liabilities",imoney(report["Liabilities"][:total],"$")))


      @pad = 0
      concat( tot_row("Income",'',"Increase"))
      @pad = 1
      children(report["Income"][:children])
      concat(tot_row("Total Income",imoney(report["Income"][:total],"$")))

      @pad = 0
      concat( tot_row("Expenses",'','Decrease'))
      @pad = 1
      children(report["Expense"][:children])
      concat( tot_row("Total Expenses",imoney(report["Expense"][:total],"$")))

      @pad = 0
      concat( tot_row("Equity",'','Decrease'))
      @pad = 1
      children(report["Equity"][:children])
      concat( tot_row("Total Equity",imoney(report["Equity"][:total],"$")))
      assets = imoney(report["Assets"][:total])
      liabilities = imoney(report["Liabilities"][:total] * -1)
      equity = imoney(report["Equity"][:total])
      income = imoney(report["Income"][:total])
      expenses = imoney(report["Expense"][:total])
      left = report["Assets"][:total] + report["Liabilities"][:total]
      right = report["Equity"][:total] + report["Income"][:total] - report["Expense"][:total]

      concat( content_tag(:h4,"Assets - Liabilities = Equity + (Income - Expenses)",class:'strong'))
      concat( content_tag(:h4,"#{assets} - (#{liabilities}) = #{equity} + (#{income} - #{expenses})",class:'strong'))
      concat( content_tag(:h4,"#{imoney(left)} =  #{imoney(right)}",class:'strong'))



      # concat( tot_row("Profit(+)/Loss(-)",imoney(report["Income"][:total] - report["Expense"][:total],"$")))
    }
  end


  def tot_row(name,amount, extra=nil)
    content_tag(:div,class:'pl-row strong') do
        concat(content_tag(:div,name,class:"pl-col-acct p#{@pad}"))
        if extra.present?
          concat(content_tag(:div,extra,class:"pl-col-1#{@level}"))
        else
          concat(content_tag(:div,'',class:"pl-col-1#{@level}"))
        end
        concat(content_tag(:div,amount,class:"pl-col-tot-#{@level}"))
      end
  end

  def pl_row(name,amount)
    content_tag(:div,class:'pl-row') do
      concat(content_tag(:div,name,class: "pl-col-acct p#{@pad}"))
      concat(content_tag(:div,imoney(amount,'$'),class: "pl-col-#{@pad}#{@level}"))
     end
  end

  def children(kids)
    kids.each do |k,v|
      if v[:children].blank?
        concat(pl_row(k,v[:amount])) unless v[:amount].zero?
      else
        if @pad == @level
          unless v[:total].zero?
            concat(pl_row(k,(v[:amount] + v[:total])))
          end
        else
          unless v[:total].zero?
            concat(pl_row(k,v[:amount]))
            @pad += 1
            children(v[:children])
            @pad -= 1
            concat(pl_row("Total "+k,v[:amount]+ v[:total]))
          end    
        end
      end
    end
  end

end
