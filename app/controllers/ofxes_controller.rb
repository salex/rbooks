class OfxesController < ApplicationController
  before_action :require_book

  def index
    @ofxes = current_book.ofxes.order(:statement_date).reverse_order
  end

  def latest
    @ofx = current_book.ofxes.order(:statement_date).last
    if @ofx.present?
      @account = @ofx.ofx_account
      render action: :show
    else
      redirect_to root_path, alert:'OFX is dependent on Bank Statements. There are no Bank Statements'
    end
  end

  def new
    # @ofx = current_book.ofxes.new
    last_statement = current_book.bank_statements.where.not(reconciled_date:nil).order(:reconciled_date).last
    bb = 0
    if last_statement.present?
      next_month = last_statement.statement_date.end_of_month + 1.day
      statement_range = Ledger.statement_range(next_month)
      bb = last_statement.ending_balance
    end
    @ofx = current_book.ofxes.new(statement_date:statement_range.last,beginning_balance:bb,ending_balance:0)

  end

  def show
    @ofx = current_book.ofxes.find(params[:id])
    @account = @ofx.ofx_account
  end

  def edit
    @ofx = current_book.ofxes.find(params[:id])
  end

  def update
    @ofx = current_book.ofxes.find(params[:id])
    uploaded_io = params[:ofx][:text_field]
    if @ofx.upload_io(uploaded_io)
      redirect_to ofxes_path, notice: "The ofx #{@ofx.key} has been uploaded."
    else
       render "edit"
    end
  end

  def create
    @ofx = current_book.ofxes.new(statement_date:Date.today.beginning_of_month)
    uploaded_io = params[:ofx][:text_field]
    if @ofx.upload_io(uploaded_io)
      redirect_to ofxes_path, notice: "The ofx #{@ofx.key} has been uploaded."
    else
       render "new"
    end
    
  end

  # def destroy
  #   @ofx = Ofx.find(params[:id])
  #   @ofx.destroy
  #   redirect_to ofxes_path, notice:  "The ofx #{@ofx.key} has been deleted."
  # end

  def link
    # authorize Entry, :trustee?
    entry = current_book.entries.find(params[:entry])
    if entry.fit_id.present?
      redirect_to latest_ofxes_path, alert:  "The Entry has already been linked!."
    else
      entry.link_ofx_transaction(params[:id])
      head :ok
    end

  end

  def new_entry
    # authorize Entry, :trustee?
    # account = current_book.accounts.new
    @options  = current_book.settings[:acct_sel_opt]
    @entry = current_book.entries.new(post_date:params[:date],
      fit_id:params[:id], numb:params[:check_number],
      description:params[:memo])
    amt = (params[:amount].to_i).abs
    # if params[:type_tran] == 'debit'
    #   amt = params[:amount].to_i * -1
    # else
    #   amt = params[:amount].to_i
    # end
    1.upto(2) do |i|
      if i == 1
        aid = nil
        if params[:type_tran] == 'debit'
          cr = amt
          db = ''
        else
          db = amt
          cr = ''
        end
      else
        aid = nil
        if params[:type_tran] == 'debit'
          db = amt
          cr = ''
        else
          cr = amt
          db = ''
        end
      end
      splits = @entry.splits.build(reconcile_state:'c',
        account_id: aid,amount:params[:amount].to_i,debit:db,credit:cr)
    end
    @entry.splits.build(reconcile_state:'n') # add extra split
    render template:'entries/new'
  end

  def matched
    match_entry = current_book.entries.find(params[:entry_id])
    if match_entry.splits.count > 2
      redirect_to latest_ofxes_path, alert:'Sorry, you can\'t duplicate entries with more than 2 splits from Bank Transactions. Deplicate it in the ledger.'
    else
      # @options  = current_book.settings[:acct_sel_opt]
      bank = Ofx.find_fit_id(params[:fit_id])
      @entry = match_entry.duplicate_with_bank(bank)
      render template:'entries/new'

    end

  end

  # def search
  #   match_entry = current_book.entries.where(Entry.arel_table[:description].matches("#{params[:lookup]}%")).order(:post_date).last
  #   if match_entry.splits.count > 2
  #     redirect_to latest_ofxes_path, alert:'Sorry, you can\'t duplicate entries with more than 2 splits from Bank Transactions. Deplicate it in the ledger.'
  #   else
  #     @options  = current_book.settings[:acct_sel_opt]

  #     bank = Ofx.find_fit_id(params[:id])
  #     @entry = match_entry.duplicate_with_bank(bank)
  #     # render plain: "#{new_entry.inspect} #{new_entry.splits.inspect} "
  #     render template: 'entries/duplicate'
  #   end

  # end

  private
    def require_book
      # puts " checking book is there from ajax"
      redirect_to(books_path, alert:'Current Book is required') if current_book.blank?
    end


  # debride not a real crud model
  # pivate
  # def ofx_params
  #   params.require(:ofx).permit(:text_field)
  # end
 
end