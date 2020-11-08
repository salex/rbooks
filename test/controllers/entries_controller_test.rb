require 'test_helper'

class EntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @entry = entries(:one)
    @book =books(:b1)
    sign_in_as users(:one)
  end

  test "should get index" do
    get entries_url
    # there is no index for entries
    assert_redirected_to accounts_url
  end

  # test "should get new" do
  #   get new_entry_url
  #   assert_response :success
  # end

  # test "should create entry" do
  #   assert_difference('Entry.count') do
  #     post entries_url, params: { entry: { book_id: @book.id, description: @entry.description, fit_id: @entry.fit_id, lock_version: @entry.lock_version, numb: @entry.numb, post_date: @entry.post_date } }
  #   end

  #   assert_redirected_to entry_url(Entry.last)
  # end

  test "should show entry" do
    get entry_url(@entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_entry_url(@entry)
    assert_response :success
  end

  # test "should update entry" do
  #   patch entry_url(@entry), params: { entry: { book_id:@book.id, description: @entry.description, fit_id: @entry.fit_id, lock_version: @entry.lock_version, numb: @entry.numb, post_date: @entry.post_date } }
  #   assert_redirected_to entry_url(@entry)
  # end

  # test "should destroy entry" do
  #   assert_difference('Entry.count', -1) do
  #     delete entry_url(@entry)
  #   end

  #   assert_redirected_to entries_url
  # end
end
