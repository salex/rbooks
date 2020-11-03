class Entries::DuplicateController < ApplicationController

  def show
    dup_entry = current_book.entries.find_by(id:params[:id])
    if dup_entry.blank?
      redirect_to( accounts_path, alert:'Entry not found for Current Book')
    else
      @entry = dup_entry.duplicate
      render template:'entries/new'
    end
  end


end