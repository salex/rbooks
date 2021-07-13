class Accounts::LedgerController < AccountsController
  # before_action :require_book
  # before_action :set_account, only: [:show]

  # GET /accounts
  def show
    # would get ledger
    render template:'accounts/actions/ledger'
  end


  def donations
    today = Date.today #- 1.year
    @range = today.beginning_of_year..today.end_of_year
    @lines = Ledger.donations(@range)
  end
 
  # private
  #   # Use callbacks to share common setup or constraints between actions.
  #   def require_book
  #     if Current.book.blank?
  #       redirect_to(books_path, alert:'Current Book is required') 
  #     else
  #       @book = Current.book
  #     end
  #   end

  #   def set_account
  #     @account = @book.accounts.find_by(id:params[:id])
  #     redirect_to( accounts_path, alert:'Account not found for Current Book') if @account.blank?
  #   end

  #   # Only allow a list of trusted parameters through.
  #   def account_params
  #     params.require(:account).permit(:uuid, :book_id, :name, :account_type, :code, :description, :placeholder, :contra, :parent_id, :level)
  #   end
end
