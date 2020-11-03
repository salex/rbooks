class Entries::VoidController < EntriesController

  def update
    not_reconciled = @entry.splits.where(reconcile_state:['y','c']).count.zero?
    respond_to do |format|
     if not_reconciled
       splits = @entry.splits.update_all(reconcile_state:'v',amount:0)
       format.html { redirect_to redirect_path, notice: 'Entry was successfully voided.' }
     else
       format.html { redirect_to redirect_path, alert: 'Entry was not voided. Splits reconciled or cleared. - Unclear or create reversing entry if reconciled' }
     end
    end
  end


end