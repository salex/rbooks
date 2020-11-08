class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  # before_action :require_login, except: [:login,:signin,:logout]
  # before_action :require_admin, except: [:login,:signin,:logout,:profile,:update_profile]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def test_signin
    user = User.first
    book = Book.first
    session[:user_id] = user.id
    session[:full_name] = user.full_name
    session[:book_id] = book.id
    session[:recent]= {}
    redirect_to root_url, notice: "Logged in! #{session[:book_id]}"
  end


  def signin
    user = User.find_by_username(params[:email].downcase) || User.find_by_email(params[:email].downcase)
    if user && user.authenticate(params[:password])
      if params[:remember_me].present?
        cookies[:remember_me] = params[:email]
      else
        cookies.delete(:remember_me)
      end
      session[:user_id] = user.id
      session[:full_name] = user.full_name
      session[:expires_at] = Time.now.midnight + 1.day
      if user.default_book.present?
        session[:book_id] = user.default_book
        book = current_book
        checking_account = book.checking_acct
        leafs = checking_account.leaf.sort
        session[:recent]= {}
        session[:recent][checking_account.id.to_s] = checking_account.name
        sub_accts = Account.find(leafs)
        sub_accts.each do |l|
          session[:recent][l.id.to_s] = l.name
        end
      end
      redirect_to root_url, notice: "Logged in!"
    else
      flash.now.alert = "Email or password is invalid"
      render "login"
    end
  end

  def logout
    reset_session
    redirect_to root_url, notice: "Logged out!"
  end

  def profile
    @user = current_user
  end

  def update_profile
    @user = User.find(params[:id])
    # authorize @user, :profile?

    respond_to do |format|
      if @user.update(user_params)
        # password and confirmation can be blank if only updating username
        format.html { redirect_to root_path, notice: 'Profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'profile' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit( :email, {:roles => []}, :username, :full_name, :password, :password_confirmation, :default_book)
    end
end

