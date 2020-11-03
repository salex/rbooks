module ReportsHelper

  # def from_period_select(date_id:nil)
  #   today = Date.today
  #   bom = today.beginning_of_month
  #   bopm = bom - 1.month
  #   boq = today.beginning_of_quarter
  #   bopq = boq - 3.months
  #   boy = today.beginning_of_year
  #   bopy = boy - 1.year
  #   qtr1 = boy
  #   qtr2 = boy + 3.months
  #   qtr3 = boy + 6.months
  #   qtr4 = boy + 9.months
  #   all = Date.new(1970,1,1)
  #   options = [
  #     ['Select From Period',nil],
  #     ['Beginning of Month',bom.to_s],
  #     ['Beginning of Quarter',boq.to_s],
  #     ['Beginning of Year',boy.to_s],
  #     ['Beginning of Prev Month',bopm.to_s],
  #     ['Beginning of Prev Quarter',bopq.to_s],
  #     ['Beginning of Prev Year',bopy.to_s],
  #     ['Quarter 1',qtr1.to_s],
  #     ['Quarter 2',qtr2.to_s],
  #     ['Quarter 3',qtr3.to_s],
  #     ['Quarter 4',qtr4.to_s],

  #     ['All',all.to_s]

  #   ]
  #   content_tag(:select,options_for_select(options), data:{behavior:'select_from_date',date_id:date_id},id: :from_select)
  # end

  # def to_period_select(date_id:nil)
  #   today = Date.today
  #   eom = today.end_of_month
  #   eopm = (eom - 1.month).end_of_month
  #   eoq = today.end_of_quarter
  #   eopq = eoq - 3.months
  #   eoy = today.end_of_year
  #   eopy = eoy - 1.year
  #   boy = today.beginning_of_year
  #   qtr1 = boy.end_of_quarter
  #   qtr2 = (boy + 3.months).end_of_quarter
  #   qtr3 = (boy + 6.months).end_of_quarter
  #   qtr4 = (boy + 9.months).end_of_quarter

  #   options = [
  #     ['Select To Period',nil],
  #     ['End of Month',eom.to_s],
  #     ['End of Quarter',eoq.to_s],
  #     ['End of Year',eoy.to_s],
  #     ['End of Prev Month',eopm.to_s],
  #     ['End of Prev Quarter',eopq.to_s],
  #     ['End of Prev Year',eopy.to_s],
  #     ['End of Quarter 1',qtr1.to_s],
  #     ['End of Quarter 2',qtr2.to_s],
  #     ['End of Quarter 3',qtr3.to_s],
  #     ['End of Quarter 4',qtr4.to_s],

  #     ['Current Date',today.to_s]

  #   ]
  #   content_tag(:select,options_for_select(options), data:{behavior:'select_to_date',date_id:date_id}, id: :to_select)
  # end

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
