class WelcomeController < ApplicationController
  def home
    session.delete(:tree_ids)
    if Current.book
      render template: 'welcome/book'
    else
      render template: 'welcome/home'
    end

  end

  def about
  end

  def test
    session[:test_list] = {1.to_s =>'c',2.to_s =>'c',3.to_s =>'c',4.to_s =>'c',5.to_s =>'c',6.to_s =>'c',7.to_s =>'c',8.to_s =>'c',9.to_s =>'c',10.to_s =>'c',
      11.to_s =>'n',12.to_s =>'n',13.to_s =>'n',14.to_s =>'n',15.to_s =>'n',16.to_s =>'n',17.to_s =>'n',18.to_s =>'n',19.to_s =>'n',20.to_s =>'n'}
  end

  def move_left1
    id = params[:id]
    session[:test_list][id] = 'c'
    # puts "move left #{session[:test_list]}"

  end

  def move_right1
    id = params[:id]
    session[:test_list][id] = 'n'
    # puts "move right #{session[:test_list]}"

  end

  def summary
    current_assets = Current.book.current_assets
    to = Date.today
    from = to.beginning_of_year
    @summary = current_assets.family_summary(from,to)
    render template:'reports/summary'
  end


  def move_two
    dir,id = params[:payload].split('|')
    puts "dir #{dir} id #{id}"
    session[:test_list][id] = dir
    puts session[:test_list]
    render partial:'welcome/testtwo'
  end

  # def move_left2
  #   payload = params[:payload]
  #   session[:test_list][id] = 'c'
  #   render partial:'welcome/testtwo'
  # end

  # def move_right2
  #   id = params[:id].to_i
  #   session[:test_list][id] = 'n'
  #   render partial:'welcome/testtwo'
  # end

end
