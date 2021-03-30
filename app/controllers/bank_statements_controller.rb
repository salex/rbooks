class BankStatementsController < ApplicationController
  before_action :require_book
  before_action :set_bank_statement, only: [:show, :edit, :update, :destroy, 
    :reconcile,:update_reconcile]

  # GET /bank_statements
  # GET /bank_statements.json
  def index
    @bank_statements = current_book.bank_statements.order(:statement_date).reverse_order
  end

  # GET /bank_statements/1
  # GET /bank_statements/1.json
  def show
  end

  # GET /bank_statements/new
  def new
    last_statement = current_book.bank_statements.where.not(reconciled_date:nil).order(:reconciled_date).last
    bb = 0
    if last_statement.present?
      next_month = last_statement.statement_date.end_of_month + 1.day
      statement_range = Ledger.statement_range(next_month)
      bb = last_statement.ending_balance
    else
      statement_range = Ledger.statement_range(Date.today)
    end
    @bank_statement = current_book.bank_statements.new(statement_date:statement_range.last,beginning_balance:bb,ending_balance:0)
  end

  # GET /bank_statements/1/edit
  def edit
  end

  # POST /bank_statements
  # POST /bank_statements.json
  def create
    @bank_statement = current_book.bank_statements.new(bank_statement_params)

    respond_to do |format|
      if @bank_statement.save
        format.html { redirect_to @bank_statement, notice: 'Bank statement was successfully created.' }
        format.json { render :show, status: :created, location: @bank_statement }
      else
        format.html { render :new }
        format.json { render json: @bank_statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /bank_statements/1
  # PATCH/PUT /bank_statements/1.json
  def update
    respond_to do |format|
      if @bank_statement.update(bank_statement_params)
        format.html { redirect_to @bank_statement, notice: 'Bank statement was successfully updated.' }
        format.json { render :show, status: :ok, location: @bank_statement }
      else
        format.html { render :edit }
        format.json { render json: @bank_statement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bank_statements/1
  # DELETE /bank_statements/1.json
  def destroy
    @bank_statement.destroy
    respond_to do |format|
      format.html { redirect_to bank_statements_url, notice: 'Bank statement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def reconcile
    session[:reconcile_id] = @bank_statement.id
    @reconcile = @bank_statement.reconcile
  end

  def clear_splits
    @bank_statement = BankStatement.find(session[:reconcile_id])
    entry = Entry.find(params[:id])
    splits = entry.splits.where(reconcile_state:'n')
    splits.update_all(reconcile_state:'c')
    @reconcile = @bank_statement.reconcile
    render partial: 'bank_statements/reconcile'
  end

  def unclear_splits
    @bank_statement = BankStatement.find(session[:reconcile_id])
    entry = Entry.find(params[:id])
    splits = entry.splits.where(reconcile_state:'c')
    splits.update_all(reconcile_state:'n')
    @reconcile = @bank_statement.reconcile
    render partial: 'bank_statements/reconcile'
  end

  def update_reconcile
    @bank_statement.reconcile

    @reconcile = @bank_statement.bank
    respond_to do |format|
      if @reconcile.cleared_splits.blank?
        format.html { redirect_to @bank_statement, notice: 'Bank statement was already reconciled.' }
      elsif @reconcile.reconcile_diff.zero?
        @reconcile.cleared_splits.update_all(reconcile_state:'y',reconcile_date:@bank_statement.statement_date + 1.day)
        @bank_statement.update(reconciled_date:@bank_statement.statement_date + 1.day)
        # update reconcile_state and reconcile_date
        session.delete(:reconcile_id)
        format.html { redirect_to @bank_statement, notice: 'Bank statement was successfully reconciled.' }
      else
        format.html { redirect_to @bank_statement, alert: "Bank statement was not reconciled. Difference = #{@reconcile[:difference]} "}
        format.json { render json: @bank_statement.errors, status: :unprocessable_entity }
      end
    end
  end




  private

    # Use callbacks to share common setup or constraints between actions.

    def set_bank_statement
      @bank_statement = current_book.bank_statements.find_by(id:params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bank_statement_params
      params.require(:bank_statement).permit(:book_id, :statement_date, :beginning_balance, :ending_balance, :ofx_data, :hash_data, :reconciled_date)
    end
end
