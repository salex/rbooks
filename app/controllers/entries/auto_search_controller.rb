class Entries::AutoSearchController < EntriesController

  def index
    @search_results = current_book.auto_search(params)
    # puts "it be searching #{@entries.count}"
    if @search_results
      render template:'shared/search_confirm',layout:false
    end
  end
end
