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
    if report['options'][:level].to_i > report['options'][:max_level].to_i
      @level = report['options'][:max_level].to_i
    else
      @level = report['options'][:level].to_i
    end
    @level = 2 if @level == 1
    content_tag(:div,class:'') {
        concat( tot_row("Income",'',"Increase"))
        children(report["Income"][:children])
        concat(tot_row("Total Income",to_money(report["Income"][:total],"$")))
        concat(tot_row("&nbsp;".html_safe,""))
        concat( tot_row("Expenses",'','Decrease'))
        children(report["Expense"][:children])
        concat( tot_row("Total Expenses",to_money(report["Expense"][:total],"$")))
        concat( tot_row("Profit(+)/Loss(-)",to_money(report["Income"][:total] - report["Expense"][:total],"$")))
      }
  end

  def trial_balance_report(report)
    @level = report['options'][:level].to_i
    content_tag(:div,class:"") { 

      concat( tot_row("Assets",'',"Increase"))
      children(report["Assets"][:children])
      concat(tot_row("Total Assest",to_money(report["Assets"][:total],"$")))

      concat( tot_row("Liabilities",'',"Increase"))
      children(report["Liabilities"][:children])
      concat(tot_row("Total Liabilities",to_money(report["Liabilities"][:total],"$")))

      concat( tot_row("Income",'',"Increase"))
      children(report["Income"][:children])
      concat(tot_row("Total Income",to_money(report["Income"][:total],"$")))

      concat( tot_row("Expenses",'','Decrease'))
      children(report["Expense"][:children])
      concat( tot_row("Total Expenses",to_money(report["Expense"][:total],"$")))

      concat( tot_row("Equity",'','Decrease'))
      children(report["Equity"][:children])
      concat( tot_row("Total Equity",to_money(report["Equity"][:total],"$")))

      assets = to_money(report["Assets"][:total])
      liabilities = to_money(report["Liabilities"][:total] * -1)
      equity = to_money(report["Equity"][:total])
      income = to_money(report["Income"][:total])
      expenses = to_money(report["Expense"][:total])
      left = report["Assets"][:total] + report["Liabilities"][:total]
      right = report["Equity"][:total] + report["Income"][:total] - report["Expense"][:total]
      concat(tag.div(class:'grid grid-cols-1 mt-4'){

        concat( content_tag(:div,"Assets - Liabilities = Equity + (Income - Expenses)",class:'strong justify-self-center'))
        concat( content_tag(:div,"#{assets} - (#{liabilities}) = #{equity} + (#{income} - #{expenses})",class:'strong justify-self-center'))
        concat( content_tag(:div,"#{to_money(left)} =  #{to_money(right)}",class:'strong justify-self-center'))
        }
      )

    }
  end

  def tot_row(name,amount, extra=nil)
    content_tag(:div,class:' strong border-b') do
      concat(content_tag(:span,name,class:"inline-block  w-56 px-2 "))
      cnt = 1
      while cnt < @level
        concat(content_tag(:span,'',class:"inline-block  w-24 text-right"))
        cnt += 1
      end
      if extra.present?
        concat(content_tag(:span,extra,class:"inline-block  px-2 w-24 text-right"))
      else
        concat(content_tag(:span,amount,class:"inline-block  px-2 w-24 text-right"))
      end
    end
  end

  def acct_row(name,amount,indent)
    content_tag(:div,class:'border-b') do
      concat(content_tag(:span,name,class: "inline-block w-56 pr-2 indent-#{(indent - 1) * 4}"))
      amt = amount.zero? ? '' : to_money(amount,'$')
      (@level - indent).times do | i|
        concat(content_tag(:span,'',class:'inline-block w-24'))
      end
      concat(content_tag(:span,amt,class: "inline-block w-24 text-right px-2"))
     end
  end

  def children(kids)
    kids.each do |k,v|
      indent = v[:level]
      if v[:children].blank?
        concat(acct_row(k,v[:amount],indent)) unless v[:amount].zero?
      else
        if indent == @level
          unless v[:total].zero?
            concat(acct_row(k,(v[:amount] + v[:total]),indent))
          end
        else

          unless v[:total].zero?
            concat(acct_row(k,v[:amount],indent))
            children(v[:children])
            concat(acct_row("Total "+k,v[:amount]+ v[:total],indent))
          end
        end  
      end
    end
  end


end
