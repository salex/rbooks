class Accounts::RegisterPdfController < AccountsController
  # before_action :require_book
  # before_action :set_account, only: [:show]

  # GET /accounts
  def show
    # would get ledger
    set_param_date
    set_account
    pdf = Pdf::Register.new(@from,@account,@to)
    send_data pdf.render, filename: "CheckingRegister-#{params[:date]}",
      type: "application/pdf",
      disposition: "inline"
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
