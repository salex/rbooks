class Report

  def trial_balance(options={})
    book = Current.book
    level = options[:level] ||= 2
    assets = book.assets_acct
    liabilities = book.liabilities_acct
    income = book.income_acct
    expenses = book.expenses_acct
    equity = book.equity_acct
    today = Date.today

    puts "Where are going work #{assets.inspect}"
    # @from = options[:from].nil? ? today.beginning_of_year  : Ledger.set_date(options[:from])
    # @to = options[:to].nil? ? today.end_of_year  : Ledger.set_date(options[:to])


    report = {
      "Assets" => {amount:period_splits(assets),total:0,children:{}},
      "Liabilities" => {amount:period_splits(liabilities),total:0,children:{}}, 
      "Income" => {amount:period_splits(income),total:0,children:{}}, 
      "Expense" =>  {amount:period_splits(expenses),total:0,children:{}},
      "Equity" => {amount:period_splits(equity),total:0,children:{}}, 
      "options" => {level:level}
    }
    tree(income,report['Income'])
    tree(expenses,report['Expense'])
    tree(assets,report['Assets'])
    tree(liabilities,report['Liabilities'])
    tree(equity,report['Equity'])
    return report
  end


  def profit_loss(options={})
    book = Current.book
    today = Date.today
    @from = options[:from].nil? ? today.beginning_of_year  : Ledger.set_date(options[:from])
    @to = options[:to].nil? ? today.end_of_year  : Ledger.set_date(options[:to])
    level = options[:level] ||= 2
    i = book.income_acct
    e = book.expenses_acct
    report = {"Income" => {amount:period_splits(i),total:0,children:{}}, 
    "Expense" =>  {amount:period_splits(e),total:0,children:{}},
    "options" => {level:level,from:@from,to:@to}}
    tree(i,report['Income'])
    tree(e,report['Expense'])
    return report
  end


  private

  def tree(branch,hash)
   branch.children.each do |c|
     hash[:children][c.name] = {amount:period_splits(c),total:0,children: {}}
     tree(c,hash[:children][c.name])
     hash[:total] += (hash[:children][c.name][:amount] + hash[:children][c.name][:total])
   end
  end

  def period_splits(acct)
    # flipper = %{INCOME EQUITY LIABILITY}.include?(acct.account_type)  ? -1 : 1
    if @from.present?
      sp = acct.splits.includes(:entry).where(entries: {post_date:@from..@to})
    else
      sp = acct.splits
    end
    sp.sum(:amount) * acct.flipper
  end


end