module EntriesHelper
  def from_period_select(date_id:nil)
    today = Date.today
    bom = today.beginning_of_month
    bopm = bom - 1.month
    boq = today.beginning_of_quarter
    bopq = boq - 3.months
    boy = today.beginning_of_year
    bopy = boy - 1.year
    qtr1 = boy
    qtr2 = boy + 3.months
    qtr3 = boy + 6.months
    qtr4 = boy + 9.months
    all = Date.new(1970,1,1)
    options = [
      ['Select From Period',nil],
      ['Beginning of Month',bom.to_s],
      ['Beginning of Quarter',boq.to_s],
      ['Beginning of Year',boy.to_s],
      ['Beginning of Prev Month',bopm.to_s],
      ['Beginning of Prev Quarter',bopq.to_s],
      ['Beginning of Prev Year',bopy.to_s],
      ['Quarter 1',qtr1.to_s],
      ['Quarter 2',qtr2.to_s],
      ['Quarter 3',qtr3.to_s],
      ['Quarter 4',qtr4.to_s],

      ['All',all.to_s]

    ]
    date = bom
    12.times do |i|
      options << [date.to_formatted_s(:month_and_year),date.to_s]
      date = date.last_month
    end

    content_tag(:select,options_for_select(options),
      class:'w-full rounded-none  px-2', id: :from_select,
      data:{
        dateRange_target:'fromOptions',
        action:'change->dateRange#fromOption',
        date_id:date_id
      })
  end

  def to_period_select(date_id:nil)
    today = Date.today
    bom = today.beginning_of_month
    eom = today.end_of_month
    eopm = (eom - 1.month).end_of_month
    eoq = today.end_of_quarter
    eopq = eoq - 3.months
    eoy = today.end_of_year
    eopy = eoy - 1.year
    boy = today.beginning_of_year
    qtr1 = boy.end_of_quarter
    qtr2 = (boy + 3.months).end_of_quarter
    qtr3 = (boy + 6.months).end_of_quarter
    qtr4 = (boy + 9.months).end_of_quarter

    options = [
      ['Select To Period',nil],
      ['End of Month',eom.to_s],
      ['End of Quarter',eoq.to_s],
      ['End of Year',eoy.to_s],
      ['End of Prev Month',eopm.to_s],
      ['End of Prev Quarter',eopq.to_s],
      ['End of Prev Year',eopy.to_s],
      ['End of Quarter 1',qtr1.to_s],
      ['End of Quarter 2',qtr2.to_s],
      ['End of Quarter 3',qtr3.to_s],
      ['End of Quarter 4',qtr4.to_s],

      ['Current Date',today.to_s]

    ]
    date = bom
    12.times do |i|
      options << [date.end_of_month.to_formatted_s(:month_and_year),date.end_of_month.to_s]
      date = date.last_month
    end

    content_tag(:select,options_for_select(options),
      class:'w-full rounded-none  px-2',id: :to_select,
        data:{
          dateRange_target:'toOptions',
          action:'change->dateRange#toOption',
          date_id:date_id
        })
  end


  # def entry_row(date,numb,desc,fit_id)

  #   html = content_tag(:tr, class: 'entry-row') {
  #     inst = content_tag(:div,"Accounts name are in reverse hierarchical order. Select a 
  #       pulldown and start typing to lookup a name!",class:"annotate")
  #     contents = ""
  #     contents << content_tag(:td, date, class:"col-e")
  #     contents << content_tag(:td, numb, class:"col-e")
  #     contents << content_tag(:td, desc, class:"col-e")
  #     contents << content_tag(:td, fit_id+inst, class:"col-e")
  #     3.times do |i|
  #       contents << content_tag(:td, nil, class:"col-e")  
  #     end
  #     contents.html_safe
  #   }.html_safe
  #   html
  # end

  # def split_row(id,eid,action,desc,trans,r,debit,credit,amount,s_id,delete,rval)
  #   html = content_tag(:tr, class: "split-row", id: "split_#{id}") {
  #     contents = ""
  #     contents << content_tag(:td, row_control(s_id,eid,delete), class:"col-hide")
  #     contents << content_tag(:td, action, class:"col-s")
  #     contents << content_tag(:td, desc, class:"col-s")
  #     contents << content_tag(:td, trans, class:"col-s")

  #     contents << content_tag(:td, ("<span>#{rval}</span>" + r).html_safe, class:"col-s w2  ",data:{action:'click->entryLedger#reconcile'})
  #     contents << content_tag(:td, debit, class:"col-s")
  #     contents << content_tag(:td, credit, class:"col-s")
  #     contents << content_tag(:td, amount, class:"col-s w3-hide")
  #     contents.html_safe
  #   }.html_safe
  #   html
  # end

  # def row_control(id_hidden,eid,delete)
  #   if eid.present?
  #     (id_hidden + delete +'<i class=" fas fa-minus-square">Del</i>'.html_safe).html_safe
  #   else
  #     (id_hidden + +'<span data-entryLedger="deletes"><i data-action="click->entryLedger#cutRow" class="fas fa-cut"></i></span>'.html_safe).html_safe
  #   end
  # end


end
