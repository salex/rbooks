class WelcomeController < ApplicationController
  def home
    if Current.book
      render template: 'welcome/book'
    else
      render template: 'welcome/home'
    end
  end

  def about
  end
  
end
