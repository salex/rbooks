Rails.application.routes.draw do

  scope module: 'vfw' do
    resources :sales_items do
      collection do
        get :liquor
        get :beer
        get :beverage
        get :food
        get :wine
        get :liquor_inventory
        patch :liquor_update
        get :beer_inventory
        get :beer_print
        get :liquor_print
        patch :beer_update
        # get :pos_update
        get :pos_download
        # patch :update_pos
        patch :downloaded
      end
      member do 
        get :buy
        patch :bought
      end
    end

    resources :deposits do
      collection do
        get :weekly
        get :month_summary
      end
      member do
        get :edit_other
        patch :update_other
      end    
    end

  end



  namespace :entries do
    resources :duplicate, only: [:show]
    resources :void, only: [:show, :update]
    resources :search, only: [:edit, :update]
    resources :filter, only: :index
    resources :filtered, only: :index
    resources :auto_search, only: :index
  end

  resources :entries

  resources :users

  namespace :books do
    resources :importyaml, only: [:new,:create]
    resources :open, only: :show
  end

  resources :books

  namespace :accounts do
    resources :bank, only: :index
    resources :ledger, only: :show
    resources :index_table, only: :index
    resources :register_pdf, only: :show
    resources :split_register_pdf, only: :show
  end

  resources :accounts

  resources :users  do
    collection do
      post :signin
    end
    member do
      patch :update_profile
      patch :reset_password
    end
  end

  resources :reports, only: :index do
    collection do
      get :profit_loss
      get :trial_balance
      get :checking_balance
      get :register_pdf
      get :split_register_pdf
      get :test
      get :summary
      get :custom
      patch :set_acct
      get :set_acct

    end
    member do
      patch :split_clear
      patch :split_unclear
    end
  end

  # namespace :vfw do
  #   # resources :audit, only: :index
  #   # resources :audit_pdf, only: :index
  #   # resources :audit_config, only: [:index,:update]
  #   resources :deposits do
  #     collection do
  #       get :weekly
  #       get :month_summary
  #     end
  #     member do
  #       get :edit_other
  #       patch :update_other
  #     end    
  #   end
  # end

  resources :bank_statements do
    member do
      get :reconcile
      get :update_reconcile
      patch :clear_splits
      patch :unclear_splits
    end
  end

  resources :ofxes do
    member do
      get :link
      get :new_entry
      get :search
      patch :search
    end
    collection do
      get :latest
      get :matched

    end
  end




  # resources :vfw do
  #   collection do
  #     get :trustee_audit
  #     get :audit
  #     get :edit_config
  #     patch :update_config
  #   end
  # end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

 
  get 'login', to: 'users#login', as: 'login'
  get 'logout', to: 'users#logout', as: 'logout'
  get 'profile', to: 'users#profile'



  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'about/about'
  get 'about/accounts'
  get 'about/entries'
  get 'about/banking'
  get 'about/reports'
  get 'about/checking'


  root "welcome#home"

end
