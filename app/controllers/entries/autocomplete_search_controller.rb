class Entries::AutocompleteSearchController < EntriesController

  def index
    @entries = current_book.autocomplete_search(params)
    # puts "it be searching #{@entries.count}"
    if @entries
      render partial:'entries/actions/acsearch_results'
    end
  end
end
