require "application_system_test_case"

class BooksTest < ApplicationSystemTestCase
  setup do
    @book = books(:one)
  end

  test "visiting the index" do
    visit books_url
    assert_selector "h1", text: "Books"
  end

  test "creating a Book" do
    visit books_url
    click_on "New Book"

    fill_in "Assets", with: @book.assets
    fill_in "Checking", with: @book.checking
    fill_in "Equity", with: @book.equity
    fill_in "Expenses", with: @book.expenses
    fill_in "Income", with: @book.income
    fill_in "Liabilities", with: @book.liabilities
    fill_in "Name", with: @book.name
    fill_in "Root", with: @book.root
    fill_in "Savings", with: @book.savings
    fill_in "Settings", with: @book.settings
    click_on "Create Book"

    assert_text "Book was successfully created"
    click_on "Back"
  end

  test "updating a Book" do
    visit books_url
    click_on "Edit", match: :first

    fill_in "Assets", with: @book.assets
    fill_in "Checking", with: @book.checking
    fill_in "Equity", with: @book.equity
    fill_in "Expenses", with: @book.expenses
    fill_in "Income", with: @book.income
    fill_in "Liabilities", with: @book.liabilities
    fill_in "Name", with: @book.name
    fill_in "Root", with: @book.root
    fill_in "Savings", with: @book.savings
    fill_in "Settings", with: @book.settings
    click_on "Update Book"

    assert_text "Book was successfully updated"
    click_on "Back"
  end

  test "destroying a Book" do
    visit books_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Book was successfully destroyed"
  end
end
