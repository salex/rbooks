class Entries::AutoSearchController < EntriesController

  def index
    @search_results = current_book.auto_search(params)
    if @search_results
      render template:'shared/search_confirm',layout:false
    end
  end
end
