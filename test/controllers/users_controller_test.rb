require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as users(:one)
    @user = users(:one)
    # puts "TTTTTTT #{current_book}"
  end

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post users_url, params: { user: { default_book: @user.default_book, email: 'new'+@user.email, full_name: @user.full_name, password: 'secret', password_confirmation: 'secret', roles: @user.roles, username:'new'+ @user.username } }
    end

    assert_redirected_to user_url(User.last)
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_user_url(@user)
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { user: { default_book: @user.default_book, email: @user.email, full_name: @user.full_name, password: 'secret', password_confirmation: 'secret', roles: @user.roles, username: @user.username } }
    assert_redirected_to user_url(@user)
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete user_url(@user)
    end

    assert_redirected_to users_url
  end
end
