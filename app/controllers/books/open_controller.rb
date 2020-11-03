class Books::OpenController < BooksController

  def show
    session[:book_id] = @book.id
    # session[:tree_ids] = @book.settings[:tree_ids]
    session.delete(:recent)
    checking_account = @book.checking_acct
    leafs = checking_account.leaf.sort
    session[:recent]= {}
    session[:recent][checking_account.id.to_s] = checking_account.name
    sub_accts = Account.find(leafs)
    sub_accts.each do |l|
      session[:recent][l.id.to_s] = l.name
    end
    
    redirect_to accounts_path
  end
end