class Entries::FilteredController < ApplicationController

  def update
    if params[:commit] == "Search Split Amount"
      entries = current_book.contains_amount_query(params[:words])
    elsif params[:commit] == "Search Entry Number"
      entries = current_book.contains_number_query(params[:words])
    elsif params[:how].present? && params[:how] == 'any'
      entries = current_book.contains_any_word_query(params[:words])
    elsif  params[:how].present? && params[:how] == 'all'
      entries = current_book.contains_all_words_query(params[:words])
    else
      entries = current_book.contains_match_query(params[:words], params[:show_all])
    end
    @lines = Ledger.entries_ledger(entries)
    # @results = EntrySearch::Component.new(entries:@lines)
    # render partial: '/entries/actions/filtered'
    # turbo_stream.replace('entries', render partial: '/entries/actions/filtered'))
    # respond_to do |format|
    #   format.turbo_stream { render turbo_stream: turbo_stream.replace('entries', render(EntrySearch::Component.new(entries:@lines)))
    #   }
    # end
    # puts @results.inspect
    # turbo_stream.replace(
    #     'entries',@results
    #   )
    # render turbo_stream: turbo_stream.replace(render_to_string(EntrySearch::Component.new(entries:@lines)))
    render turbo_stream: turbo_stream.replace(
      'entries',
      partial: '/entries/actions/filtered')
 

  end
end