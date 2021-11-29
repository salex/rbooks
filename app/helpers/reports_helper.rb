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
      concat(tot_row("Total Income","",to_money(report["Income"][:total],"$")))
      @pad = 0
      concat( tot_row("Expenses",'','Decrease'))
      @pad = 1
      children(report["Expense"][:children])
      concat( tot_row("Total Expenses","",to_money(report["Expense"][:total],"$")))
      concat( tot_row("Profit(+)/Loss(-)","",to_money(report["Income"][:total] - report["Expense"][:total],"$")))
    }
  end

  def trial_balance_report(report)
    @level = report['options'][:level].to_i
    content_tag(:div) { 
      @pad = 0
      concat( tot_row("Assets",'',"Increase"))
      @pad = 1
      children(report["Assets"][:children])
      concat(tot_row("Total Assest",to_money(report["Assets"][:total],"$")))

      @pad = 0
      concat( tot_row("Liabilities",'',"Increase"))
      @pad = 1
      children(report["Liabilities"][:children])
      concat(tot_row("Total Liabilities",to_money(report["Liabilities"][:total],"$")))


      @pad = 0
      concat( tot_row("Income",'',"Increase"))
      @pad = 1
      children(report["Income"][:children])
      concat(tot_row("Total Income",to_money(report["Income"][:total],"$")))

      @pad = 0
      concat( tot_row("Expenses",'','Decrease'))
      @pad = 1
      children(report["Expense"][:children])
      concat( tot_row("Total Expenses",to_money(report["Expense"][:total],"$")))

      @pad = 0
      concat( tot_row("Equity",'','Decrease'))
      @pad = 1
      children(report["Equity"][:children])
      concat( tot_row("Total Equity",to_money(report["Equity"][:total],"$")))
      assets = to_money(report["Assets"][:total])
      liabilities = to_money(report["Liabilities"][:total] * -1)
      equity = to_money(report["Equity"][:total])
      income = to_money(report["Income"][:total])
      expenses = to_money(report["Expense"][:total])
      left = report["Assets"][:total] + report["Liabilities"][:total]
      right = report["Equity"][:total] + report["Income"][:total] - report["Expense"][:total]

      concat( content_tag(:h4,"Assets - Liabilities = Equity + (Income - Expenses)",class:'strong'))
      concat( content_tag(:h4,"#{assets} - (#{liabilities}) = #{equity} + (#{income} - #{expenses})",class:'strong'))
      concat( content_tag(:h4,"#{to_money(left)} =  #{to_money(right)}",class:'strong'))



      # concat( tot_row("Profit(+)/Loss(-)",to_money(report["Income"][:total] - report["Expense"][:total],"$")))
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
      concat(content_tag(:div,to_money(amount,'$'),class: "pl-col-#{@pad}#{@level}"))
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
