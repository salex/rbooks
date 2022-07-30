class Report

  def trial_balance(options={})
    book = Current.book
    @max_level = book.accounts.maximum(:level)
    level = options[:level] ||= @max_level
    assets = book.assets_acct
    liabilities = book.liabilities_acct
    income = book.income_acct
    expenses = book.expenses_acct
    equity = book.equity_acct
    today = Date.today

    # puts "Where are going work #{assets.inspect}"
    if options[:from].present?
      @from = options[:from].nil? ? today.beginning_of_year  : Ledger.set_date(options[:from])
      @to = options[:to].nil? ? today.end_of_year  : Ledger.set_date(options[:to])
    end

    report = {
      "Assets" => {amount:period_splits(assets),total:0,children:{}},
      "Liabilities" => {amount:period_splits(liabilities),total:0,children:{}}, 
      "Income" => {amount:period_splits(income),total:0,children:{}}, 
      "Expense" =>  {amount:period_splits(expenses),total:0,children:{}},
      "Equity" => {amount:period_splits(equity),total:0,children:{}}, 
      "options" => {level:level,from:@from,to:@to}
    }
    @depth = 0
    tree(income,report['Income'])
    @depth = 0
    tree(expenses,report['Expense'])
    @depth = 0
    tree(assets,report['Assets'])
    @depth = 0
    tree(liabilities,report['Liabilities'])
    @depth = 0
    tree(equity,report['Equity'])
    return report
  end


  def profit_loss(options={})
    book = Current.book
    today = Date.today
    @from = options[:from].nil? ? today.beginning_of_year  : Ledger.set_date(options[:from])
    @to = options[:to].nil? ? today.end_of_year  : Ledger.set_date(options[:to])
    level = options[:level] ||= 2
    max_level = book.accounts.maximum(:level)
    i = book.income_acct
    e = book.expenses_acct
    report = {"Income" => {amount:period_splits(i),total:0,children:{}}, 
      "Expense" =>  {amount:period_splits(e),total:0,children:{}},
      "options" => {level:level,from:@from,to:@to,max_level:max_level}
    }
    @max_level = 0
    @depth = 0
    tree(i,report['Income'])
    @depth = 0
    tree(e,report['Expense'])
    report['options'][:max_level] -= 1  # last inc not used
    return report
  end


  private

  def tree(branch,hash)
    @max_level = @depth if @depth > @max_level
    @depth += 1  
    branch.children.each do |c|
      hash[:children][c.name] = {amount:period_splits(c),total:0,children: {},level:@depth+1}
      tree(c,hash[:children][c.name])
      hash[:total] += (hash[:children][c.name][:amount] + hash[:children][c.name][:total])
      @depth -= 1 
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