class Entries::FilterController < EntriesController
  def index
    render template:'entries/actions/search_filter'
  end

 end