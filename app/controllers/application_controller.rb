class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include UsersHelper
  # makes sign_out abailable

  before_action :current_book
  before_action :current_user
  # before_action :session_expiry
  # before_action :config_set
  

  def current_user
    @current_user ||= User.find_by(id:session[:user_id]) if session[:user_id]
    Current.user = @current_user
    @current_user
  end
  helper_method :current_user

  def current_book
    if session[:book_id]
      @current_book ||= Book.find_by(id:session[:book_id])
    # else
    #   @current_book ||= Book.first
    end
    Current.book =@current_book 
    if @current_book.present? && @current_book.settings.blank?
      @current_book.get_settings
    end
    @current_book
  end
  helper_method :current_book

  def tree_ids
    # tree_id control account options
    if session[:recent].blank?
      session[:recent] = {}
    end
    # the session[:tree_ids] is destroyed with any account change that resets settings
    @tree_ids = current_book.settings[:tree_ids]
  end
  helper_method :tree_ids


  def require_login
    if current_user.nil? 
      redirect_to root_url, alert: "I'm sorry. I can't do that."
    end
  end
  helper_method :require_login

  def require_trustee
    if current_user.blank? || !current_user.is_trustee?
      redirect_to root_url, alert: "I'm sorry. I can't - or You can't do that."
    end
  end
  helper_method :require_trustee

  def require_admin
    if current_user.blank? || !current_user.is_admin?
      redirect_to root_url, alert: "I'm sorry. I can't - or You can't do that."
    end
  end
  helper_method :require_admin


end
