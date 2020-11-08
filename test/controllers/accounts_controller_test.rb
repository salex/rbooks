require 'test_helper'

class AccountsControllerTest < ActionDispatch::IntegrationTest


  setup do
    sign_in_as users(:one)
    @account = accounts(:a6)
  end

  test "should get index" do
    get accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_account_url, params:{parent_id:@account.id}
    assert_response :success
  end

  test "should create account" do
    assert_difference('Account.count') do
      post accounts_url, params: { account: { account_type: @account.account_type, book_id: @account.book_id, code: @account.code, contra: @account.contra, description: @account.description, level: @account.level, name: @account.name, parent_id: @account.parent_id, placeholder: @account.placeholder, uuid: @account.uuid } }
    end
    assert_redirected_to account_url(Account.last)
  end

  test "should show account" do
    get account_url(@account)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_url(@account)
    assert_response :success
  end

  test "should update account" do
    patch account_url(@account), params: { account: { account_type: @account.account_type, book_id:@account.book_id, code: @account.code, contra: @account.contra, description: @account.description, level: @account.level, name: @account.name, parent_id: @account.parent_id, placeholder: @account.placeholder, uuid: @account.uuid } }
    assert_redirected_to account_url(@account)
  end

  test "should destroy account" do
    assert_difference('Account.count', -1) do
      delete account_url(@account)
    end

    assert_redirected_to accounts_url
  end
end
