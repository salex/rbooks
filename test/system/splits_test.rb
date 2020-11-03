require "application_system_test_case"

class SplitsTest < ApplicationSystemTestCase
  setup do
    @split = splits(:one)
  end

  test "visiting the index" do
    visit splits_url
    assert_selector "h1", text: "Splits"
  end

  test "creating a Split" do
    visit splits_url
    click_on "New Split"

    fill_in "Account", with: @split.account_id
    fill_in "Action", with: @split.action
    fill_in "Amount", with: @split.amount
    fill_in "Entry", with: @split.entry_id
    fill_in "Lock version", with: @split.lock_version
    fill_in "Memo", with: @split.memo
    fill_in "Reconcile date", with: @split.reconcile_date
    fill_in "Reconcile state", with: @split.reconcile_state
    click_on "Create Split"

    assert_text "Split was successfully created"
    click_on "Back"
  end

  test "updating a Split" do
    visit splits_url
    click_on "Edit", match: :first

    fill_in "Account", with: @split.account_id
    fill_in "Action", with: @split.action
    fill_in "Amount", with: @split.amount
    fill_in "Entry", with: @split.entry_id
    fill_in "Lock version", with: @split.lock_version
    fill_in "Memo", with: @split.memo
    fill_in "Reconcile date", with: @split.reconcile_date
    fill_in "Reconcile state", with: @split.reconcile_state
    click_on "Update Split"

    assert_text "Split was successfully updated"
    click_on "Back"
  end

  test "destroying a Split" do
    visit splits_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Split was successfully destroyed"
  end
end
