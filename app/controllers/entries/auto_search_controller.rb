class Entries::AutoSearchController < EntriesController

  def index
    @entries = current_book.auto_search(params)
    puts "it be searching #{@entries.count}"
    if @entries
      render partial:'entries/actions/search_results'
    end
  end
end