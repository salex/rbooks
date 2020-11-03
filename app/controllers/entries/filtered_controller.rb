class Entries::FilteredController < ApplicationController

  def index
    if params[:commit] == "Search Split Amount"
      entries = current_book.contains_amount_query(params[:words])
    elsif params[:commit] == "Search Entry Number"
      entries = current_book.contains_number_query(params[:words])
    elsif params[:how].present? && params[:how] == 'any'
      entries = current_book.contains_any_word_query(params[:words])
    elsif  params[:how].present? && params[:how] == 'all'
      entries = current_book.contains_all_words_query(params[:words])
    else
      entries = current_book.contains_match_query(params[:words])
    end
    @lines = Book.entries_ledger(entries)
    render partial: '/entries/actions/filtered'
  end
end