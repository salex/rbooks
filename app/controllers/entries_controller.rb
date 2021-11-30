class EntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy, :duplicate]
  before_action :require_book
  # GET /entries
  # GET /entries.json
  def index
    redirect_to accounts_path, notice:'Entries can only be accsessed through Accounts'
  end

  # GET /entries/1
  # GET /entries/1.json
  def show
  end

  # GET /entries/new
  def new
    # authorize Entry, :trustee?
    if params[:account_id].present?
      account = Account.find(params[:account_id])
    else 
      account = Account.new
    end
    # @options  = Stash.find_by(key:'acct_sel_opt').hash_data
    @entry = current_book.entries.new(post_date:Date.today)
    1.upto(3) do |i|
      aid = i == 1 ? account.id : nil
      splits = @entry.splits.build(reconcile_state:'n',account_id: aid, amount:0, debit:0)
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @list }
    end
  end

  # GET /entries/1/edit
  def edit
    2.times{@entry.splits.build(reconcile_state:'n')}

  end

  # POST /entries
  # POST /entries.json
  def create
    @entry = current_book.entries.new(entry_params)
    # authorize Entry, :trustee?
    @bank_dup = @entry.fit_id.present?
    respond_to do |format|
      if @entry.valid_params?(entry_params) && @entry.save
        format.html { redirect_to redirect_path, notice: 'Entry was successfully created.' }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { render :new }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end  # PATCH/PUT /entries/1
  # PATCH/PUT /entries/1.json
  def update
    respond_to do |format|
      if @entry.valid_params?(entry_params) && @entry.update(entry_params)
        format.html { redirect_to redirect_path, notice: 'Entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
    rescue ActiveRecord::StaleObjectError
      respond_to do |format|
        format.html {
          flash[:alert] = "This project has been updated while you were editing. Please refresh to see the latest version."
          render :edit
        }
        format.json { render json: { error: "Stale object." } }
      end
    
  end

  # DELETE /entries/1
  # DELETE /entries/1.json
  def destroy
    @entry.destroy
    respond_to do |format|
      format.html { redirect_to redirect_path, notice: 'Entry was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def redirect_path
      if @bank_dup.present?
        latest_ofxes_path
      elsif session[:current_acct].present?
        account_path(session[:current_acct])
      else
        account_path(@entry.splits.order(:id).first.account)
      end
    end

    def set_entry
      @entry = current_book.entries.find_by(id:params[:id])
      # puts "WAS CALLED #{@entry.blank?} #{params[:id]}"
      redirect_to( accounts_path, alert:'Entry not found for Current Book') if @entry.blank?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def entry_params
      params.require(:entry).permit(:numb, :post_date, :description, :fit_id, :book_id,
        splits_attributes: [:id,:action,:memo,:amount,:reconcile_state,:account_id,:debit,:credit,:_destroy])
    end
end
