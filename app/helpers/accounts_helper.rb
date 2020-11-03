module AccountsHelper
  def acct_list(root,p=0)
    if params[:tree].present?
      return acct_tree(root)
    end
    html = content_tag(:div, class: 'pl-row') {
      ul_contents = ""
      # ul_contents << content_tag(:div, link_to(root.name,account_checkbooks_path(guid:root.guid)), class:"col-acct p#{p}")
      ul_contents << content_tag(:div, link_to(root.name,account_path(root)), class:"col-acct p#{p}")

      ul_contents << content_tag(:div,node_balance(root),class:'pl-col-11')
      p +=1
      root.children.each do |child|
        ul_contents << acct_list(child,p)
      end
      p -= 1
      ul_contents.html_safe
    }.html_safe
  end

  def summary_list(root,p=0)
    if params[:tree].present?
      return acct_tree(root)
    end
    html = content_tag(:div, class: 'pl-row') {
      ul_contents = ""
      # ul_contents << content_tag(:div, link_to(root.name,account_checkbooks_path(guid:root.guid)), class:"col-acct p#{p}")
      ul_contents << content_tag(:div, link_to(root.name,account_path(root)), class:"summary-acct p#{p}")

      ul_contents << content_tag(:div,node_balance(root),class:'pl-summary')
      p +=1
      root.children.each do |child|
        ul_contents << summary_list(child,p)
      end
      p -= 1
      ul_contents.html_safe
    }.html_safe
  end


  def acct_tree(root,p=0)
    html = content_tag(:div, class: 'pl-row') {
      ul_contents = ""
      ul_contents << content_tag(:div, root.name, class:"col-acct p#{p}")
      p +=1
      root.children.each do |child|
        ul_contents << acct_tree(child,p)
      end
      p -= 1
      ul_contents.html_safe
    }.html_safe
  end

  def node_balance(acct)
    b = acct.family_balance
    b.zero? ? "" : imoney(b,'$')
  end

  def imoney(pennies,unit="")
   return "" if pennies.zero?
    dollars = pennies / 100
    cents = (pennies % 100) / 100.0
    amount = dollars + cents
    number_to_currency(amount,unit:unit)
  end

  def money(pennies,unit="")
   pennies = 0 if pennies.blank?
    dollars = pennies / 100
    cents = (pennies % 100) / 100.0
    amount = dollars + cents
    number_to_currency(amount,unit:unit)
  end


  def to_money(int)
    dollars = int / 100
    cents = (int % 100) / 100.0
    amt = dollars + cents
    number_to_currency(amt,unit:'')
  end

  def report_select_options(account_id,url,other=nil)
    options = []
    if account_id.present?
      options << ['Custom Dates',"#{url}?fromto=1&account=#{account_id}"]
    else
      options << ['Custom Dates',"#{url}?fromto=1"]
    end

    date = Date.today.beginning_of_month
    12.times do |i|
      this_url = url+"?date=#{date.to_s}"
      if account_id.present?
        this_url = this_url + "&account=#{account_id}"
      end
      this_url = this_url + other if other.present?
      options << [date.to_formatted_s(:month_and_year),this_url]
      date = date.last_month
    end
    options
  end

end
