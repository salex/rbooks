class Accounts::IndexTableController < AccountsController
  # before_action :require_book
  # before_action :set_account, only: [:show]

  # GET /accounts
  def index
    @accounts = Current.book.accounts.find(tree_ids)
    render template:'accounts/index_table'
  end

end
