class AccountsController < ApplicationController
  before_action :require_book
  before_action :set_account, only: [:show, :edit, :update, :destroy]


  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Current.book.accounts.find(tree_ids)
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    set_recent if params[:toggle].present?
    @date = Date.today # not used but thinking
    set_param_date
    session[:current_acct] = @account.id
    render template:'accounts/ledger/show'
  end

  # GET /accounts/new
  def new
    @parent = Current.book.accounts.find_by(id:params[:parent_id])
    @account = Current.book.accounts.new(uuid:SecureRandom.uuid,parent_id:@parent.id,level:@parent.level+1)
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Current.book.accounts.new(account_params)

    respond_to do |format|
     if @account.save
       format.html { redirect_to @account, notice: 'Account was successfully created.' }
       format.json { render :show, status: :created, location: @account }
     else
       format.html { render :new }
       format.json { render json: @account.errors, status: :unprocessable_entity }
     end
    end
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url, notice: 'Account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_param_date
      # sets datas based on params or last transaction
      #  if params include a date from/to converted to beginning and end of month
      #  if only from will set from and to (or today of to missing)
      #  if parmans not present will get last transaction and set from to beginning of its month
      #  if from is in current month, may look back 7 days from from date
      @today = Date.today
      minus7 = @today.day < 8 ? 8  - @today.day : 0 # if in first week of month, look back 7 days
      if params[:date].present? # from month pulldown
        @date = Ledger.set_date(params[:date])
        @from = @date.beginning_of_month
        @to = @date.end_of_month
      elsif params[:from].present? # from date picker(from,to)
        @from = Ledger.set_date(params[:from])
        @to = params[:to].present? ? Ledger.set_date(params[:to]) : @today.end_of_month
      else
        last_tran = @account.last_entry_date ||= @today.beginning_of_year
        @from = last_tran.beginning_of_month
        @from -= minus7 if Ledger.dates_in_same_month(@today,@from)
        @to = @today.end_of_month
      end
    end

    def set_account
      @account = Current.book.accounts.find_by(id:params[:id])
      redirect_to( accounts_path, alert:'Account not found for Current Book') if @account.blank?
    end

    def set_recent
      if session[:recent] && session[:recent].has_key?(@account.id.to_s)
        session[:recent].delete(@account.id.to_s) 
      else
        session[:recent][@account.id.to_s] = @account.name
      end
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:uuid, :book_id, :name, :account_type, :code, :description, :placeholder, :contra, :parent_id, :level)
    end
end
